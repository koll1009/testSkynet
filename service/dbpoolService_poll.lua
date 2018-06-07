local skynet = require "skynet"
local logger = require "liblog"

local runconf = require(skynet.getenv("runconfig"))

local maxnum = runconf.service.mysql.maxnum
local mysqlName=runconf.service.mysql.servicename
local dbpool = {}

local function init()
    for i = 1, maxnum do
        dbpool[i] = string.format(".%s%d",mysqlName, i) 
    end
    
end

local next_id = 0
local function next_connection()
    local id=next_id%maxnum+1
    next_id = next_id + 1
    return dbpool[id]
end

local function fetch_connection(key)
    if type(key) == "number" then
        return dbpool[key]
    else
        return next_connection()
    end
end

local function lua_dispatch(session,source,...)
    local conn=next_connection()
    skynet.redirect(conn,source,"lua",session,skynet.pack(...))
    logger.info("已转发到%s",conn)
end



skynet.init(init)

skynet.start(function()
    logger.info(" dbpool started! ")
    skynet.dispatch("lua",lua_dispatch)
end
)



 


