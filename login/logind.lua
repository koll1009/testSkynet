local skynet=require "skynet"
local logger=require "liblog"
local cluster=require "cluster"
local login=require "snax.login_Service"
local runconf=require "runconfig"
local NetApi=require "NetApi"

local server =runconf.service.server.loginserver
local game={} --保存游戏服务器
local game_proxy={} --保存rpc地址
local CMD={} --master的lua消息处理命令集
local user_token={} 

math.randomseed(tostring(os.time()):reverse():sub(1, 7))
local function auth(token)
    --return "123"    

    return math.random(1,1000)
end

--登录服务器接收到客户端认证信息后调用
--暂定为认证成功后返回服务器列表，所以server不用发
 function server.auth_handler(token)
    logger.info("in auth handle,token is %s",token)
	local ret = string.split(token, ":")
	local token = ret[1]  
    local sdkid = tonumber(ret[2]) 
    local uid = auth(token, sdkid) --认证
    logger.info("in auth handle,uid is %d",uid)
    --logger.debug"auth ss"
	if not uid then
		logger.error("auth failed")
		error("auth failed")
    end
	return uid 
end

local sid=0
function server.login_handler(uid,secret,token)
   -- logger.debug(type(uid))
    local u=user_token[tostring(uid)]

    --已登录，kick
    if u and u.gameserver and game_proxy[u.gameserver] then 
        logger.info("%s is already online",uid)
        --使用pcall是因为，游服可能宕机，此时skynet.call会报错,此错误可以当作正常现象，替换掉用户凭证
        pcall(skynet.call,game_proxy[u.gameserver],"lua","kick",uid) --此时uid要全服唯一
    end

    --也有可能用户通过登录验证，但迟迟没有选择游服，则覆盖掉，这样登录游服时会因为密钥和sid的不一致而失败
    user_token[tostring(uid)]={
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
        return sid,game --返回服务器内编号和游戏服信息
    end
end

local running=false
local function logout_game(nodename)
    logger.info("game server %s logout",nodename)
    game[nodename]=nil
    game_proxy[nodename]=nil
    if table.empty(game_proxy) then 
        logger.debug("game proxy is null")
        running=false
    end
end


--心跳检测
local function heartbeat()
    skynet.fork(function()
        local ind={}
        local interval=server.hbinterval
        skynet.sleep(interval)
        while running do 
            local gsnum=table.size(game_proxy)
            logger.debug("game servers count %d",gsnum)
            local pinterval=interval/gsnum
            local key,value=next(game_proxy)
            while key do
                logger.debug("%s:heartbeat",key)
                local ok=pcall(skynet.call,value,"lua","heartbeat")
                if not ok then
                    local i=ind[key]
                    i=(i or 0)+1
                    logger.debug("%s lost %d times",key,i)
                    if i==3 then 
                         logout_game(key)
                         ind[key]=nil
                    else
                        ind[key]=i
                    end
                else
                    ind[key]=0
                end
                key,value=next(game_proxy,key)
                skynet.sleep(pinterval)
            end
        end
    end)
end


--注册新游服
function CMD.register_game(nodename,host,port,servicename)
	logger.info("new game server is opening,name is %s,servicename is %s,addr is %s:%d",nodename,"."..servicename,host,port)

	if game[nodename] then
		return "this nodename is occupied"
    else
        game_proxy[nodename]=cluster.proxy(nodename,"."..servicename)
        game[nodename]={
            host=host,
            port=port,
            users=0
        }

        if not running then
            running=true
           -- heartbeat()
        end
	end
end

--注销游服
function CMD.logout_game(nodename)
    logout_game(nodename)
end

--用户登录
function CMD.login_user(uid,nodename)
    logger.info("user:%s login ,gameserver:%s",uid,nodename)
    local g=game[nodename]
    assert(g)
    g.users=g.users+1
    local u=user_token[uid]
    assert(u)
    u.gameserver=nodename
end

--用户下线
function CMD.logout_user(uid,nodename)
    logger.info("user:%s logout ,gameserver:%s",uid,nodename)
    local g=game[nodename]
    assert(g)
    g.users=g.users-1
    user_token[uid]=nil
end

function CMD.auth(uid)
    return user_token[uid] --可以改成登录服验证，这样需要单独传递密钥
end

--lua消息处理
function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f( ...)
end

local index=...
login(server,index or 0)
