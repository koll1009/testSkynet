local skynet = require "skynet"
local logger = require "liblog"


local runconf = require(skynet.getenv("runconfig"))

local maxnum = runconf.service.redis.maxnum
local redisName=runconf.service.redis.servicename
local dbpool = {}
local CMD={}

local function init()
    for i = 1, maxnum do
        dbpool[i] = string.format(".%s%d",redisName, i) 
    end
    
end

local next_id = 0
local function next_connection()
    local id=next_id%maxnum+1
    next_id = next_id + 1
    logger.debug(" redirect to next %s ",dbpool[id])
    return dbpool[id],id
end

local function fetch_connection(key)
    if type(key) == "number" then
        logger.debug(" redirect to fetch %s ",dbpool[key])
        return dbpool[key]
    else
        return next_connection()
    end
end

setmetatable(CMD, { __index = function(t,k)
	local cmd = string.upper(k)
    local f = function (...)
        local conn=next_connection();
		return skynet.call(conn,"lua",cmd,...)
	end
	t[k] = f
	return f
end})


init()

return CMD