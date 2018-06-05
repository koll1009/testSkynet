local skynet= require "skynet"
local logger=require "log"
--logger.set_name("startService")
skynet.start(function()
    logger.info("start!")
    logger.warn("warning")
    logger.error("error")
    skynet.newservice("console")
    skynet.newservice("debug_console",8000)
    skynet.exit()
end)