local logger=require "liblog"
local redis=require "skynet.db.redis"
local skynet=require "skynet"
local runconf = require(skynet.getenv("runconfig"))local runconf = require(skynet.getenv("runconfig"))

local servicename,index=...
local db={}

skynet.register_protocol{
    name="client",
    id=skynet.PTYPE_CLIENT,
    pack=skynet.pack,
    unpack=skynet.unpack
}

skynet.start(function()
    if  servicename and  index then
        logger.set_name(servicename..index)
    end
    skynet.dispatch("lua",function(session,source,cmd,...)
        assert(cmd)
        local f=db[cmd]     
        skynet.ret(skynet.pack(f(db,...)))
    end
    )

    db=redis.connect(runconf.service.redis.connection)
end
)
