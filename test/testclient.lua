 

local socket = require "socket"
local crypt = require "crypt"
local runconf=require "runconfig"
local skynet=require "skynet"
local logger=require "liblog"

local LOGIN_HOST = runconf.service.server.loginserver.host
local LOGIN_PORT = runconf.service.server.loginserver.port 

local GAME_HOST = runconf.service.server.gameserver[1].host
local GAME_PORT = runconf.service.server.gameserver[2].port

local gameserver = "gameserver1"

local fd

local secret

local USERNAME
local UID

local session = 0

string.split = function(s, delim)
    local split = {}
    local pattern = "[^" .. delim .. "]+"
    string.gsub(s, pattern, function(v) table.insert(split, v) end)
    return split
end

local function send_package( text)  --以size+data的方式发送
    local package = string.pack(">s2", text)
	 socket.write(fd, package)
end

local function read_package()
	local ret=socket.read(fd, 2)
	local sz = (string.byte(ret) << 8) + string.byte(ret, 2)
	return socket.read(fd, sz)
end

local CMD = {}

function CMD.help(  )
	local info = 
	[[
		"Usage":testclient cmd arg[1] arg[2] ...
		- help
		- login token sdkid
	]]
	logger.info(info)
end

local index = 0

function CMD.login(token, sdkid, noclose)
	assert(token and sdkid)

	-- 以下代码登录 loginserver
	fd = assert(socket.open(LOGIN_HOST, LOGIN_PORT))
	if fd then 
		logger.debug("connect to %s:%s",LOGIN_HOST,LOGIN_PORT)
	end

	local challenge = crypt.base64decode(read_package())	-- 读取用于握手验证的challenge

	local clientkey = crypt.randomkey()	-- 用于交换secret的clientkey
	send_package(crypt.base64encode(crypt.dhexchange(clientkey)))
	local serverkey = crypt.base64decode(read_package())	-- 读取serverkey
	secret = crypt.dhsecret(serverkey, clientkey)		-- 计算私钥

	logger.debug("sceret is %s", crypt.hexencode(secret))

	local hmac = crypt.hmac64(challenge, secret)
	send_package(crypt.base64encode(hmac))		-- 回应服务器第一步握手的挑战码，确认握手正常

	token = string.format("%s:%s:%s", gameserver, token, sdkid)
	local etoken = crypt.desencode(secret, token)
	send_package(crypt.base64encode(etoken))

	local result = read_package()
	local code = tonumber(string.sub(result, 1, 3))
	--assert(code == 200)
	socket.close(fd)	-- 认证成功，断开与登录服务器的连接

	local user = crypt.base64decode(string.sub(result, 4,#result))		-- base64(uid:subid)
	logger.dedug(user)
	local result = string.split(user, ":")
	UID = tonumber(result[1])

	print(string.format("login ok, user %s, uid %d", user, UID))
 --[[ 
	-- 以下代码与游戏服务器握手
	fd = assert(socket.connect(GAME_HOST, GAME_PORT))
	index = index + 1
	local handshake = string.format("%s@%s#%s:%d",
		crypt.base64encode(result[1]),
		crypt.base64encode(gameserver),
		crypt.base64encode(result[2]),
		index)
	print("handshake=%s", handshake)
	local hmac = crypt.hmac_hash(secret, handshake)

	send_package(handshake .. ":" .. crypt.base64encode(hmac))

	result = read_package()
	code = tonumber(string.sub(result, 1, 3))
	assert(code == 200)

	if not noclose then
		socket.close(fd)
	end

	print("handshake ok")
	--]]
end

local function encode(name, data)
	local payload = protobuf.encode(name, data)
	local netmsg = { name = name, payload = payload }
	local pack = protobuf.encode("netmsg.NetMsg", netmsg)
	return pack
end

local function decode(data)
	local netmsg = protobuf.decode("netmsg.NetMsg", data)

	return netmsg
end

function CMD.roleinit(token, sdkid, name)
	CMD.login(token, sdkid, true)

	local data = { name = name }
	send_request(encode("user.RoleInitRequest", data))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("role init succ")
	end
end

function CMD.rolerename(token, sdkid, name)
	CMD.login(token, sdkid, true)

	local data = { name = name }
	send_request(encode("user.RoleRenameRequest", data))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("role rename succ")
	end
end

function CMD.userinfo(token, sdkid)
	CMD.login(token, sdkid, true)

	send_request(encode("user.UserInfoRequest", {}))
	local ok, msg, sess = recv_response(read_package())
	msg = decode(msg)
	if msg then
		print("userinfo succ")
	end
end

local function start(cmd, ...)
	if not cmd or cmd == "" then
		cmd = "help"
	end
	local f = assert(CMD[cmd], cmd .. " not found")
	f(...)
end

local args = { ... }

--start(table.unpack(args))
skynet.start(function() 
	start(table.unpack(args))
	skynet.exit()
end)

