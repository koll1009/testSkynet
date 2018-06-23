local login = require "snax.login_server"
local crypt = require "crypt"
local skynet = require "skynet"
local snax = require "snax"
local cluster = require "cluster"
local logger=require "liblog"
local runconf=require "runconfig"


local server = runconf.service.server.loginserver

local user_online = {}	-- 记录玩家所登录的服务器



local function register(token, sdkid)
 
end

local function auth(token, sdkid)
	 return 1
end

--客户身份验证，args为客户信息，赞约定为server:user token:sdkid
function server.auth_handler(args)
	local ret = string.split(args, ":")
	logger.debug(tostring(ret))
	--assert(#ret == 3)
	local server = ret[1] 
	local token = ret[2]  
	local sdkid = tonumber(ret[3]) 
	 


	logger.error("auth_handler is performing server=%s token=%s sdkid=%d", server, token, sdkid)
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
		logger.info( "%d is online already,call gameserver %s to kick uid=%d subid=%d ...", uid,last.server, uid, last.subid)
		local ok = pcall(cluster.call, last.server, "gated", "kick", uid, last.subid)  
		if not ok then
			user_online[uid] = nil
		end
	end

	
	if user_online[uid] then
		logger.error("user %d is already online", uid)
		error(string.format("user %d is already online", uid))
	end

	-- 登录游戏服务器
	logger.info("uid=%d is logging to gameserver %s ...", uid, server)
	local ok, subid = pcall(cluster.call, server, "gated", "login", uid, secret) --调用游戏服务器的login服务
	if not ok then
		logger.error("login gameserver error")
		error("login gameserver error")
	end
	logger.info("uid=%d logged on gameserver %s subid=%d ...", uid, server, subid)
	user_online[uid] = { subid = subid, server = server } --在线登记
	return subid
end

local CMD = {}

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		logger.info("%d@%s#%d is logout", uid, u.server, subid)
		user_online[uid] = nil
	end
end

function server.command_handler(command, source, ...)
	local f = assert(CMD[command])
	return f(source, ...)
end

login(server)	-- 启动登录服务器
