local skynet = require "skynet"
local queue = require "skynet.queue"
local socket=require "socket"
local libsend=require "libsender"
local modules=require "libmanager" 
local NetApi=require "NetApi"
local mysql=require"libdbpool"

local cs = queue()
local CMD = {}
local HANDLES={}
local agent={watchers={}}
local start=true
 

function CMD.init(conf)
	logger.info("the agent inited for user %s",tostring(conf))
	start=true
	agent.fd = conf.client_fd  
    agent.secret=conf.secret
	agent.uid=conf.uid
	agent.sid=conf.sid
	agent.gate=conf.gate
	libsend.SetSock(conf.client_fd)	
	local strSql=string.format("select * from PlayerData where Uid='%s'",agent.uid)
	logger.debug("query player info :%s",strSql)
	local status,ret=mysql.execute(strSql)
	if status==0 and ret[1]~=nil then 
	   agent.playerdata=ret[1]
	else
	   logger.warn("query player info:%s failed,errmsg is %s",strSql,ret)
	end
	local path=skynet.getenv "module_path"
	modules.load_modules(path)
	modules.init(agent)
end


function CMD.kick()
	skynet.call(".aoi","lua","Leave")
	start=false 
	agent={watchers={},player_data={}}
	modules.close()
end



function CMD.add_watcher(w,wposition,mposition)
	local fd=agent.fd
	agent.watchers[w]=wposition
	modules.sync_PlayerData(w)
	modules.sync_PlayerEquipment(w,agent.uid)
	skynet.send(w,"lua","sync_position",agent.uid,mposition)
end

function CMD.sync_playerData(playerdata)
	modules.sendPlayerData(playerdata)
end

function CMD.sync_position(uid,pos)
	modules.sendOtherPlayerUpdateData(uid,pos)
end

function CMD.sync_PlayerEquipment(uid,equipment)
	modules.sendOtherPlayerEquipment(uid,equipment)
end

function CMD.sync_skill(sid,tid,skid)
	modules.sendOtherPlayerUseSkill(sid,tid,skid)
end


function HANDLES.sync_monster(source,mid,type,position)
	modules.sendMonsterData(source,mid,type,position)
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
		if not start then 
			return 
		end

		local f = CMD[command]
		if  f then 
			cs(f, ...)
			return 
		end
		local h=HANDLES[command]
		if  h then 
			h(source,...)
		end
	end)
end)
