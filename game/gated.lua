local crypt = require "crypt"
local skynet = require "skynet"
local cluster = require "cluster"
local logger=require "liblog"
local runconf = require(skynet.getenv("runconfig")) 

local gateserver = require "snax.gateserver"
local netpack = require "netpack"
local socketdriver = require "socketdriver"
local b64encode = crypt.base64encode
local b64decode = crypt.base64decode

local CMD = {}	
local user_online = {}	
local connection={}	
local agent_pool = {}

local nodename=runconf.service.server.gameserver.nodename
local login=runconf.service.server.loginserver.nodename
local loginservice="."..runconf.service.server.loginserver.servicename

CMD.expired_number = 128

local max_agent
local curr_agent

--网关的init命令，用于初始化agent pool
function CMD.init()
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

--kick，主动下线在线用户
function CMD.kick(uid)
    logger.info("kick user %s from %s",uid,nodename)
    local u=user_online[uid]
    local agent=connection[u.fd].agent

    --1.关闭fd
    gateserver.closeclient(u.fd)

    --2.清空用户缓存
    user_online[uid]=nil
    connection[u.fd]=nil 

    --3.关闭
    pcall(skynet.call,agent,"lua","kick")
    table.insert(agent_pool,agent)

    --4.通知login server
    pcall(cluster.call,login,loginservice,"logout_user",uid,nodename)
end

--心跳包
function CMD.heartbeat()

end


skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handshake = {}	
local handler = {}
-- 内部命令处理
function handler.command(cmd, source, ...)
    --logger.debug(cmd)
    local f = assert(CMD[cmd])
    return f(...)
end

-- 网关服务器open后回调，向login server注册信息
function handler.open(source, gateconf)
    cluster.call(login,loginservice,"register_game",gateconf.nodename,gateconf.address or "0.0.0.0",gateconf.port,gateconf.servicename)
end

-- 接收到客户端连接
function handler.connect(fd, addr)
    handshake[fd] = addr  --保存fd和客户端ip地址
    gateserver.openclient(fd) --开启数据接收
end

-- 连接断开回调
function handler.disconnect(fd)
    handshake[fd] = nil
    local c = connection[fd]
    if c then
        logger.debug(c.uid)
        CMD.kick(c.uid)
    end
end

-- socket发生错误时回调
handler.error = handler.disconnect


local function getuid(token)
    local uid, sid, sdkid = token:match "([^@]*)@([^#]*)#(.*)"
	return b64decode(uid), b64decode(sid), b64decode(sdkid)
end
local function do_auth(fd, message, addr)
    local username, hmac = string.match(message, "([^:]*):([^:]*)")
    local uid,sid,sdkid=getuid(username)
    logger.debug("recv a client handshake info ,uid:%s,sid:%s,sdkid:%s",uid,sid,sdkid)

    --登录服取信息
    local ok,ret=pcall(cluster.call,login,loginservice,"auth",uid)
    if not ok then 
        logger.error("auth login service failed")
        error("auth login service failed")
    elseif not ret then 
        return "404 User not found"
    end
    --logger.debug(tostring(ret))

    --使用密钥，验证信息的一致性
    local v = b64encode(crypt.hmac_hash(ret.secret, username))
    if v~=hmac then 
        return "401 Unauthorized"
    end
    
    --验证通过，保存在线用户信息
    local u={}
    u.fd = fd  --fd
    u.ip = addr --客户端地址
    u.secret=ret.secret
    u.uid=uid
    u.sid=sid
    u.sdkid=sdkid
    user_online[uid]=u

    local agent = table.remove(agent_pool)
	if not agent then
		if curr_agent < max_agent then
			agent = skynet.newservice "msgagent"
			curr_agent = curr_agent + 1
		else
			logger.error("too many agents")
			error("too many agents")
		end
    end
    skynet.call(agent,"lua","init",{ gate=skynet.self(),uid=uid,client_fd=fd,secret=ret.secret })
    connection[fd]={
        agent=agent,
        uid=uid
    }

    --在登录服务器注册
    cluster.call(login,loginservice,"login_user",uid,nodename)
    
end

local function auth(fd, addr, msg, sz)
    local message = netpack.tostring(msg, sz) 

    local ok, result = pcall(do_auth, fd, message, addr)
    if not ok then
        logger.warnning(result)
        result = "400 Bad Request"
    end

    logger.debug(type(result))
    local close = result ~= nil

    if result == nil then
        result = "200 OK"
    end

    socketdriver.send(fd, netpack.pack(result))

    if close then
        gateserver.closeclient(fd)
    end
end



local function do_request(fd, message)
    local u = assert(connection[fd], "invalid fd")
   -- local size = string.unpack(">I4", message)
   -- message = message:sub(1,-5)
    logger.debug(type(message))
    skynet.redirect(u.agent,0,"client",fd,message)
end

local function request(fd, msg, sz)
    local message = netpack.tostring(msg, sz)
    logger.debug("recv data:%s",message)
    local ok, err = pcall(do_request, fd, message)
    -- not atomic, may yield
    if not ok then
        logger.warn("Invalid package %s : %s", err, message)
        if connection[fd] then
            gateserver.closeclient(fd)
        end
    end
end

-- 接收到socket data时回调
function handler.message(fd, msg, sz)
    local addr = handshake[fd]
    if addr then
        auth(fd,addr,msg,sz) --进行认证
        handshake[fd] = nil
    else
        request(fd, msg, sz)
    end
end

gateserver.start(handler)


	


