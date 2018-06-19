local skynet = require "skynet"
local logger=require "liblog"

local command = {}
local gate
 

--网关会把接收到的数据转发到clusterd服务处理
function command.socket(source, subcmd, fd, msg)
	if subcmd == "data" then --监听到数据
		 
	elseif subcmd == "open" then --监听到连接 

		logger.info("accept from %s",msg)
		skynet.send(gate,"lua","accept",fd)


	elseif subcmd=="close" then --关闭
	
	else 

	end
end

skynet.start(function()
	gate = skynet.newservice("gate") --开启一个网关服务，用于接收所有的登录
	skynet.call(gate, "lua", "open", { address = "127.0.0.1", port = 8808 }) --监听
	skynet.dispatch("lua", function(session , source, cmd, ...)
		local f = assert(command[cmd])
		f(source, ...)
	end)
end)
