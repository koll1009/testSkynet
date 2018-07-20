local start=...
local skynet= require "skynet"
local logger=require "liblog"
require "skynet.manager"
local cluster=require "cluster"
local runconf = require(skynet.getenv("runconfig"))

logger.set_name("startService")

local function start_gameserver()
    logger.info("now start gameserver  !")
   -- skynet.newservice("LoadDataService")
    local rods=skynet.newservice("ReadonlyLoadDataService")
    skynet.name(".ReadonlyLoadDataService",rods)

    local gameconf=runconf.service.server.gameserver
    logger.debug("gameconf %s",tostring(gameconf))
    local gate=skynet.uniqueservice("gated")
    skynet.name("."..gameconf.servicename,gate)
    skynet.call(gate,"lua","init")--初�?�化
    skynet.call(gate,"lua","open",gameconf)
    
    local aoi=skynet.uniqueservice("aoiService")
    skynet.name(".aoi",aoi)
    
    cluster.open(gameconf.nodename)

    skynet.newservice("sv_managerService","192.168.224.129",8888)
    
    
end

local function start_mysql()
    logger.info("now start mysql service!")
    local maxnum=runconf.service.mysql.maxnum
    for index=1,maxnum do
        local addr=skynet.newservice(runconf.service.mysql.servicename,runconf.service.mysql.servicename,index)
        skynet.name("."..runconf.service.mysql.servicename..index,addr)
    end
end

local function start_redis()
    logger.info("now start redis service!")
    local maxnum=runconf.service.redis.maxnum
    for index=1,maxnum do
        local addr=skynet.newservice(runconf.service.redis.servicename,runconf.service.redis.servicename,index)
        skynet.name("."..runconf.service.redis.servicename..index,addr)
    end

end

local function start_login()
    logger.info("now start login service")
    local login=skynet.newservice( "logind" ) 
    local loginconf=runconf.service.server.loginserver
    --logger.debug("login conf is %s",tostring(loginconf))
    cluster.open(loginconf.nodename) --部署多服节点
end

local function init(start)
    if start=="login" then 
        start_login()
    elseif start=="game" then
        start_gameserver()
    else
        logger.error("error server type,just game or login")
    end      
end

local builder=require "skynet.datasheet.builder"
local datasheet=require "skynet.datasheet"
skynet.start(function()
    logger.info("%s server start,version is %s!",start,runconf.version)
    init(start)
    --start_gateway()
    --start_mysql()
    --start_redis()
    
    --skynet.newservice("testmysql",1)
    --skynet.newservice("console")
    skynet.exit()
end)