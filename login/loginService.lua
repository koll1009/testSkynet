local login = require "snax.login_server"
local crypt = require "crypt"
local skynet = require "skynet"
local snax = require "snax"
local cluster = require "cluster"
local logger=require "liblog"
local runconf=require "runconfig"

local server =runconf.service.server.loginserver

local user_online = {}	-- 记录玩家所登录的服务器
local game={} --记录所有游戏服务器



local function register(token, sdkid)
 
end

local function auth(token, sdkid)
	 return "123"
end

--客户身份验证，args为客户信息，赞约定为server:user token:sdkid
function server.auth_handler(args)
	local ret = string.split(args, ":")
	logger.debug(tostring(ret))
	--assert(#ret == 3)
	local server = ret[1] 
	local token = ret[2]  
	local sdkid = tonumber(ret[3]) 
	 
	logger.debug("auth_handler is performing server=%s token=%s sdkid=%d", server, token, sdkid)
	local uid = auth(token, sdkid) --认证函数
	if not uid then
		logger.error("auth failed")
		error("auth failed")--此时accept会报错
	end
	return server, uid  --返回游戏服务器信息以及用户id
end

-- 认证成功后，回调此函数，登录游戏服务器，server为服务器信息，uid为用户信息，secret为密钥
function server.login_handler(server, uid, secret)
	 
	local last = user_online[uid] --查询在线用户表

	if last then --已在线的先kick
		logger.debug( "%d is online already,call gameserver %s to kick uid=%d subid=%d ...", uid,last.server, uid, last.subid)
		--local ok = pcall(skynet.call,game[server],"lua","kick", uid, last.subid)  
		if not ok then
			user_online[uid] = nil
		end
	end

	
	if user_online[uid] then
		logger.error("user %d is already online", uid)
		error(string.format("user %d is already online", uid))
	end

	-- 登录游戏服务器
	logger.debug("uid=%s is 登录游戏服务器 %s ...", uid, server)
	assert(game[server])

	local ok, subid = pcall(skynet.call,game[server],"lua","login", uid, secret) --调用游戏服务器的login服务,内部传输，暂定明文
	if not ok then
		logger.error("login gameserver error")
		error("login gameserver error")
	end
	logger.debug("uid=%s logged on gameserver %s subid=%d ...", uid, server, subid)
	user_online[uid] = { subid = subid, server = server } --在线登记
	return subid
end

local CMD = {}

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		logger.debug("%d@%s#%d is logout", uid, u.server, subid)
		user_online[uid] = nil
	end
end

function CMD.register_game(nodename,servicename)
	logger.debug("new game server is openning,name is %s,servicename is %s",nodename,"."..servicename)

	if game[nodename] then
		return 0,"this nodename is occupied"
	else
		game[nodename]=cluster.proxy(nodename,"."..servicename)
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f( ...)
end

login(server)	-- 启动登录服务器
