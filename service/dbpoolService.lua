local skynet = require "skynet"
local logger = require "liblog"

local runconf = require(skynet.getenv("runconfig"))

local maxnum = runconf.service.mysql.maxnum
local mysqlName=runconf.service.mysql.servicename
local dbpool = {}
local sleep_coroutine={}
local client={}

local function init()
    for i = 1, maxnum do
         table.insert(dbpool, mysqlName..i)
    end
    
end

local function wait()
    local co=coroutine.running()
    table.insert(sleep_coroutine,co)
    skynet.wait(co) --歇菜
end

local function wakeup()
    if next(sleep_coroutine) then
        local co=table.remove(sleep_coroutine,1)
        skynet.wakeup(co)
    end
end


local function lua_dispatch(session,source,...)
    while true do
        if next(dbpool) then 
            local conn=table.remove(dbpool)
            logger.debug(conn)
            logger.debug(session)
            skynet.redirect(conn,source,"lua",session,skynet.pack(...))
            logger.info("已转发到%s",conn)
            break
        else 
            wait()
        end
    end
end


 function client.back(index)
    table.insert(dbpool,mysqlName..index)
    wakeup()
end

local function client_dispatch(session,source,cmd,...)
    local f=client[cmd]
    if not f then 
        f(...)
    else
        logger.error("illegal cmd form %d ",source)
    end
end
skynet.register_protocol{
    name="client",
    id=skynet.PTYPE_CLIENT,
    pack=skynet.pack,
    unpack=skynet.unpack,
    dispatch=client_dispatch 
}

skynet.init(init)

skynet.start(function()
    logger.info(" dbpool npoll started! ")
    skynet.dispatch("lua",lua_dispatch)
end
)



 


