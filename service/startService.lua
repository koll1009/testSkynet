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
        local addr=skynet.newservice(runconf.service.mysql.servicename,runconf.service.mysql.servicename,index)
        skynet.name("."..runconf.service.mysql.servicename..index,addr)
    end

    logger.info("now start dbpool")
    local addr=skynet.newservice("dbpoolService")
    skynet.name(".mysqlpool",addr)

end

local function start_redis()
    logger.info("now start redis service")
    local addr=skynet.newservice("redisService")
    skynet.name(".redis",addr)

end

skynet.start(function()
    logger.info("server start,version is %s!",runconf.version)
    start_gateway()
    start_mysql()
    start_redis()

    --skynet.newservice("testmysql",1)
    skynet.newservice("console")
    skynet.exit()
end)