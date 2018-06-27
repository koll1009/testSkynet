local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"
local netpack = require "netpack"
local logger=require "liblog"


local cs = queue()
local CMD = {}
local agent

--当玩家通过login and game server双重认证后，会分配一个agent，并初始化
function CMD.init(source,conf)
	logger.info("the agent inited for user %s",tostring(conf))
	agent=conf
end


function CMD.kick()
	agent=nil
end

local function msg_unpack(msg, sz)
	logger.debug(type(msg))
	logger.debug(skynet.tostring(msg,sz))

end

local function msg_pack(data)
	 
end

local function msg_dispatch(netmsg)
	 
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,

	unpack = function (msg, sz)
		return msg_unpack(msg, sz)
	end,

	dispatch = function (_, _, netmsg)
		msg_dispatch(netmsg)
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.retpack(cs(f, source, ...))
	end)
end)
