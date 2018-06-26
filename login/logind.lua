local skynet=require "skynet"
local logger=require "liblog"
local cluster=require "cluster"
local login=require "snax.login_Service"
local runconf=require "runconfig"

local server =runconf.service.server.loginserver
local game={} --保存游戏服务器
local game_proxy={} --保存rpc地址
local CMD={} --master的lua消息处理命令集
local user_token={} 

local function auth(token,sdkid)
    return "123" 
end

--登录服务器接收到客户端认证信息后调用，token格式暂定为user token:sdkid
--暂定为认证成功后返回服务器列表，所以server不用发
 function server.auth_handler(token)
    logger.debug("recv auth info:%s",token)
	local ret = string.split(token, ":")

	local token = ret[1]  
	local sdkid = tonumber(ret[2]) 
    local uid = auth(token, sdkid) --认证
    logger.debug"auth ss"
	if not uid then
		logger.error("auth failed")
		error("auth failed")
    end
	return uid 
end

local sid=0
function server.login_handler(uid,secret,token)
   -- logger.debug(type(uid))

    user_token[uid]={
        uid=uid,
        sid=sid,
        secret=secret,
        token=token
    }
    sid=sid+1
    if table.empty(game) then 
        logger.error("no game server started")
        error("no game server started")
    else
        return sid,game
    end
end

--注册新游服
function CMD.register_game(nodename,host,port,servicename)
	logger.debug("new game server is opening,name is %s,servicename is %s,addr is %s:%d",nodename,"."..servicename,host,port)

	if game[nodename] then
		return "this nodename is occupied"
	else
        game_proxy[nodename]=cluster.proxy(nodename,"."..servicename)
        game[nodename]={
            host=host,
            port=port,
            users=0
        }
	end
end

--注销游服
function CMD.logout_game(nodename)
    game[nodename]=nil
    game_proxy[nodename]=nil
end

--用户登录
function CMD.login_user(nodename)
    local g=game[nodename]
    assert(g)
    g.users=g.users+1
end

--用户下线
function CMD.logout_user(nodename)
    local g=game[nodename]
    assert(g)
    g.users=g.users-1
end

function CMD.auth(uid)
    return user_token[uid]
end

--lua消息处理
function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f( ...)
end

local index=...
login(server,index or 0)
