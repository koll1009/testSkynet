local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"
local netpack = require "netpack"
local logger=require "liblog"
local socket=require "socket"
local runconf = require(skynet.getenv("runconfig"))
local gameconf=runconf.service.server.gameserver


local cs = queue()
local CMD = {}
local agent={}

--当玩家通过login and game server双重认证后，会分配一个agent，并初始化
function CMD.init(source,conf)
	logger.info("the agent inited for user %s",tostring(conf))
	agent.fd = conf.fd  --fd
    agent.secret=conf.secret
    agent.uid=conf.uid
    agent.sid=conf.sid
end


function CMD.kick()
	agent=nil
end

function CMD.enter_aoi(x,y,z,o)
	skynet.call(".aoi","lua","player_enter",x,y,z,o)
end

function CMD.update_aoi(x,y,z,o)
	skynet.call(".aoi","lua","update_position",x,y,z,o)
end

function CMD.async_aoi(markerid,x,y,z)
	local fd=agent.fd
	local uid=skynet.call("."..gameconf.servicename,"lua","getuid",markerid)
	socket.write(fd,uid..x..y..z)
end


local function msg_unpack(msg, sz)
	return skynet.tostring(msg,sz)
end

local function msg_pack(data)
	   
end



local function msg_dispatch(netmsg)
	
	local NetApi=require "NetApi"
	NetApi.receiveMsg(netmsg)

	skynet.ignoreret() --gate分发而来，不需要ret

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
