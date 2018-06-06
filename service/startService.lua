local skynet= require "skynet"
local logger=require "liblog"
require "skynet.manager"
local runconf = require(skynet.getenv("runconfig"))

logger.set_name("startService")
local function start_gateway()
    logger.info("now start gateway!")
    local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	skynet.error("Watchdog listen on", 8888)
end

local function start_mysql()
    logger.info("now start mysql service!")
    local maxnum=runconf.service.mysql.maxnum
    for index=1,maxnum do
        local addr=skynet.newservice(runconf.service.mysql.servicename)
        skynet.name("."..runconf.service.mysql.servicename..index,addr)
    end
end

skynet.start(function()
    logger.info("start!")
    start_gateway()
    start_mysql()
    skynet.newservice("console")
    logger.warn("test")
    logger.error("test")
    skynet.exit()
end)