local msgserver = require "snax.msg_server"
local crypt = require "crypt"
local skynet = require "skynet"
local cluster = require "cluster"
local logger=require "liblog"
local runconf = require(skynet.getenv("runconfig")) 

local server = {}
local users = {}		-- uid -> u
local username_map = {}		-- username -> u
local internal_id = 0
local agent_pool = {}

local nodename=runconf.service.server.gameserver.nodename
local login=runconf.service.server.loginserver.nodename
local loginservice="."..runconf.service.server.loginserver.servicename

server.expired_number = 128

local max_agent
local curr_agent

--网关的init函数，用于初始化agent pool
function server.init_handler()
	local maxclient = (tonumber(skynet.getenv("maxclient")) or 1024)
	local n = maxclient // 10
	logger.info("precreate %d agents", n)
	for i = 1, n do
		local agent = assert(skynet.newservice("msgagent"), string.format("precreate agent %d of %d error", i, n))
		table.insert(agent_pool, agent)
	end
	max_agent = 2 * maxclient
	curr_agent = n
end

-- 客户端与游戏服务器handshake成功后回调
function server.auth_handler(username, fd)
	local uid = msgserver.userid(username)
	--uid = tonumber(uid)
 
	local agent = table.remove(agent_pool) --取一个agent服务
	if not agent then
		if curr_agent < max_agent then
			agent = skynet.newservice "msgagent"
			curr_agent = curr_agent + 1
		else
			logger.error("too many agents")
			error("too many agents")
		end
	end
	users[uid].agent=agent --分配agent
	skynet.call(agent, "lua", "init", users[uid])	-- 通知agent认证成功，玩家真正处于登录状态了
end

function server.online_handler(uid, fd)
	--skynet.call(users[uid].agent, "lua", "online", uid, fd)
end


-- login命令的处理函数，玩家通过登录服务器认证后，调用此函数 uid用户id secret密钥
function server.login_handler(uid, secret)
	logger.info(" a client acquired login certification，user is %s，sec is %s",uid,secret)
	if users[uid] then
		logger.error("%d is already login", uid)
		error(errmsg)
	end

	internal_id = internal_id + 1 --分配服务器内部id
 
	local username = msgserver.username(uid, internal_id, nodename) --通过用户id，服务器内部id和服务器名生成唯一用户名
	
	local u = {
		username = username,
		uid = uid,
		subid = internal_id,
		sc=secret
	}

	users[uid] = u
	username_map[username] = u

	msgserver.login(username, secret) --记录密钥，用于解密

	return internal_id
end


-- 内部命令logout处理函数
function server.logout_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, NODE_NAME)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[uid] = nil
		username_map[u.username] = nil
		
		pcall(cluster.call, login, ".login_master", "logout", uid, subid)
		table.insert(agent_pool, u.agent)
	end
end

-- call by login server
-- 内部命令kick处理函数
-- 玩家登录 登录服务器，发现用户已登录到其他游戏服务器，调用此函数踢掉
function server.kick_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, NODE_NAME)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	else
		--这里是为了防止msgserver崩溃后，未通知loginserver而导致卡号
		pcall(cluster.call, login, loginservice, "logout", uid, subid)
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk")
	end
end

function server.request_handler(username, msg)
	local u = username_map[username]
	return skynet.tostring(skynet.rawcall(u.agent, "client", msg))
end

-- 网关open后，注册登记函数,向login server注册自身信息
function server.register_handler(nodename,servicename)
	pcall(cluster.call,login,loginservice,"register_game",nodename,servicename)
end

-- 获取所有的在线agent列表
function server.get_agents()
	local agnets = {}
	for k, v in pairs(users) do
		agents[k] = v.agent
	end
	return agents
end

-- 获取在线玩家uid所对应的agent
function server.get_agent(uid)
	if users[uid] then
		return users[uid].agent
	end
end

function server.is_online(uid)
	if users[uid] then
		return true
	else
		return false
	end
end

msgserver.start(server)		-- 启动游戏服务器
