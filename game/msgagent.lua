local skynet = require "skynet"
local queue = require "skynet.queue"
local socket=require "socket"
local NetApi=require "NetApi"
require "modules.aoi_module"


local cs = queue()
local CMD = {}
local agent={}

--当玩家通过login and game server双重认证后，会分配一个agent，并初始化
function CMD.init(conf)
	logger.info("the agent inited for user %s",tostring(conf))
	agent.fd = conf.client_fd  --fd
    agent.secret=conf.secret
    agent.uid=conf.uid
	agent.sid=conf.sid
	agent.gate=conf.gate
end


function CMD.kick()
	skynet.call(".aoi","lua","player_leave")
	agent=nil
end

local socket_error = {}

local function assert_socket(service, v, fd)
	if v then
		return v
	else
		logger.error("%s failed: socket (fd = %d) closed", service, fd)
		error(socket_error)
	end
end

local function write(service, fd, text)  --以size+data的方式发送
    local package = string.pack(">s2", text)
	assert_socket(service, socket.write(fd, package), fd) 
end

function CMD.async_aoi(marker_agent,x,y,z,o)
	local fd=agent.fd

	local uid=type(marker_agent)=="boolean" and "npc" or skynet.call(agent.gate,"lua","getuid",marker_agent)
	write("agent",fd,"uid:"..uid.." x:"..x.." y:"..y.." z:"..z.." o:"..o)
end


local function msg_unpack(msg, sz)
	return skynet.tostring(msg,sz)
end

local function msg_pack(data)
	   
end



local function msg_dispatch(netmsg)
	
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
		skynet.retpack(cs(f, ...))
	end)
end)
