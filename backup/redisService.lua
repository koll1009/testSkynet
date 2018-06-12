local logger=require "liblog"
local redis=require "skynet.db.redis"
local skynet=require "skynet"
local c = require "skynet.core"
local runconf = require(skynet.getenv("runconfig"))local runconf = require(skynet.getenv("runconfig"))

local servicename,index,testTT=...
local db={}
local timeout=runconf.service.redis.timeout  
local timeout_session={}

skynet.start(function()
    if  servicename and  index then
        logger.set_name(servicename..index)
    end
    skynet.dispatch("lua",function(session,source,cmd,...)
        assert(cmd)
        local arg={...}
        if timeout and timeout>0 then
            skynet.timeout(timeout,function()
                if  not timeout_session[(source<<32)|session] then    
                    timeout_session[(source<<32)|session]=0
                    --logger.debug("timeout from %08x,command is %s",source,cmd .." "..table.concat(arg," "))
                    c.send(source, skynet.PTYPE_RESPONSE, session, skynet.pack("timeout")) 
                else
                    timeout_session[(source<<32)|session]=nil
                end
            end)
            local f=db[cmd]   
            local data=f(db,...)
            if testTT then 
                skynet.sleep(testTT) 
            end
            if not timeout_session[(source<<32)|session] then  
                timeout_session[(source<<32)|session]=1             
                skynet.retpack(data)
            else
                timeout_session[(source<<32)|session]=nil
                skynet.ignoreret()
            end

        else
            skynet.retpack(db[cmd](db,...))
        end
       logger.debug("%d",#timeout_session)
    end
    )

    db=redis.connect(runconf.service.redis.connection)
end
)
