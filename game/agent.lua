local skynet = require "skynet"
local queue = require "skynet.queue"
local socket=require "socket"
local libsend=require "libsender"
local modules=require "libmanager" 

local cs = queue()
local CMD = {}
local agent={}
agent.watchers={}
 

function CMD.init(conf)
	logger.info("the agent inited for user %s",tostring(conf))
	agent.fd = conf.client_fd  
    agent.secret=conf.secret
	agent.uid=conf.uid
	agent.sid=conf.sid
	agent.gate=conf.gate
	libsend.SetSock(conf.client_fd)	
	local path=skynet.getenv "module_path"
	modules.load_modules(path)
	modules.init(agent.watchers,conf.uid)
end


function CMD.kick()
	skynet.call(".aoi","lua","player_leave")
	agent={}
	agent.watchers={}
	modules.close()
end



function CMD.add_watcher(w,wposition,mposition)
	local fd=agent.fd
	agent.watchers[w]=wposition
	skynet.send(w,"lua","sync_position",agent.uid,mposition.x,mposition.y,mposition.z,mposition.o)
end

function CMD.sync_position(uid,x,y,z,o)
	modules.sendOtherPlayerUpdateData(uid,x,y,z,o)
end

function CMD.sync_skill(sid,tid,skid)
	modules.sendOtherPlayerUseSkill(sid,tid,skid)
end

local function msg_unpack(msg, sz)
	return skynet.tostring(msg,sz)
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
