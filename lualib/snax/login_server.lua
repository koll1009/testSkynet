-- 该模块以snax.loginserver为模板修改而来
local skynet = require "skynet"
require "skynet.manager"
local socket = require "socket"
local crypt = require "crypt"
local table = table
local string = string
local assert = assert
local logger=require "liblog"

--[[

Protocol:

	line (\n) based text protocol

	1. Server->Client : base64(8bytes random challenge)
	2. Client->Server : base64(8bytes handshake client key)
	3. Server: Gen a 8bytes handshake server key
	4. Server->Client : base64(DH-Exchange(server key))
	5. Server/Client secret := DH-Secret(client key/server key)
	6. Client->Server : base64(HMAC(challenge, secret))
	7. Client->Server : DES(secret, base64(token))
	8. Server : call auth_handler(token) -> server, uid (A user defined method)
	9. Server : call login_handler(server, uid, secret) ->subid (A user defined method)
	10. Server->Client : 200 base64(subid)

Error Code:
	400 Bad Request . challenge failed
	401 Unauthorized . unauthorized by auth_handler
	403 Forbidden . login_handler failed
	406 Not Acceptable . already in login (disallow multi login)

Success:
	200 base64(uid:subid)
]]

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

local function read(service, fd)
	local ret = assert_socket(service, socket.read(fd, 2), fd)
	local sz = (string.byte(ret) << 8) + string.byte(ret, 2)
	assert(sz > 0, "error size " .. sz)

	return socket.read(fd, sz)
end

local function launch_slave(auth_handler)
	local function auth(fd, addr)
        logger.debug("connect from %s (fd = %d)", addr, fd)
        
		socket.start(fd)

		-- set socket buffer limit (8K)
		-- If the attacker send large package, close the socket
		socket.limit(fd, 8192)

		local challenge = crypt.randomkey()   
		write("auth", fd, crypt.base64encode(challenge))

		local handshake = read("auth", fd)
		local clientkey = crypt.base64decode(handshake)
		if #clientkey ~= 8 then
			logger.error("Invalid client key")
			error "Invalid client key"
		end
		local serverkey = crypt.randomkey()
		write("auth", fd, crypt.base64encode(crypt.dhexchange(serverkey)))

		local secret = crypt.dhsecret(clientkey, serverkey)

		logger.debug("server secret is %s",crypt.hexencode(secret))

		local response = read("auth", fd)
		local hmac = crypt.hmac64(challenge, secret) --hmac加密challenge 看看是否和客户端发送过的验证一直

		if hmac ~= crypt.base64decode(response) then
			write("auth", fd, "400 Bad Request\n")
			logger.error("challenge failed")
			error "challenge failed"
		end

		local etoken = read("auth", fd)

		local token = crypt.desdecode(secret, crypt.base64decode(etoken)) --解密token数据

		logger.debug("server receive token %s",token)
		local ok, server, uid = pcall(auth_handler, token) --调用认证函数

		return ok, server, uid, secret
	end

	local function ret_pack(fd, ok, err, ...)
		socket.abandon(fd)
		if ok then
			skynet.ret(skynet.pack(err, ...))
		else
			if err == socket_error then
				skynet.ret(skynet.pack(nil, "socket error"))
			else
				skynet.ret(skynet.pack(false, err))
			end
		end
	end

	skynet.dispatch("lua", function(_,_,fd,...)
		if type(fd) ~= "number" then
			skynet.ret(skynet.pack(false, "invalid fd type"))
		else
			ret_pack(fd,pcall(auth, fd, ...))
		end
	end)

end

local user_login = {}	-- key:uid value:true 表示玩家登录记录

local function accept(conf, s, fd, addr)
	 
	local ok, server, uid, secret = skynet.call(s, "lua",  fd, addr) --调用slave处理认证过程，返回游服信息，用户id以及密钥
	socket.start(fd)  

	-- 认证失败，有两种可能，nil是socket error，false是认证失败
	if not ok then
		if ok ~= nil then
			logger.debug("401 Unauthorized")
			write("response 401", fd, "401 Unauthorized")
		end
		error(server)
	end

	-- 一个用户在走登录流程时，禁止同一用户在别处登录
	if not conf.multilogin then
		if user_login[uid] then
			write("response 406", fd, "406 Not Acceptable")
			LOG_ERROR("406 Not Acceptable uid=%d", uid)
			error(string.format("User %s is already login", uid))
		end

		user_login[uid] = true
    end
    
	-- 回调登录服务器login_hander
	local ok, err = pcall(conf.login_handler, server, uid, secret)

	user_login[uid] = nil	

	if ok then
		err = err or ""
		write("response 200", fd, "200 "..crypt.base64encode(uid .. ":" .. err))
	else
		logger.debug("403 Forbidden uid=%d", uid)
		write("response 403", fd, "403 Forbidden")
		error(err)
	end
end

local function launch_master(conf)
	local instance = conf.instance or 8
	assert(instance > 0)
	local host = conf.host or "0.0.0.0"
	local port = assert(tonumber(conf.port))
	local slave = {}
	local balance = 1

	skynet.dispatch("lua", function(_,source,command, ...)
		skynet.ret(skynet.pack(conf.command_handler(command, ...)))
	end)

	for i=1,instance do
		table.insert(slave, skynet.newservice(SERVICE_NAME))
	end

	skynet.error(string.format("login server listen at : %s %d", host, port))
	local id = socket.listen(host, port)
	socket.start(id , function(fd, addr)
	
		local s = slave[balance]
		balance = balance + 1
		if balance > #slave then
			balance = 1
		end
		local ok, err = pcall(accept, conf, s, fd, addr)
		if not ok then
			if err ~= socket_error then
				logger.debug( "invalid client (fd = %d) error = %s", fd, err)
			end
			socket.start(fd)
		end
		socket.close(fd)
	end)
end

local function login(conf)
	local name = "." .. (conf.name or "login")
	skynet.start(function()
		local loginmaster = skynet.localname(name)	--查询loginmaster地址
		if loginmaster then
			local auth_handler = assert(conf.auth_handler)
			launch_master = nil
			conf = nil
			launch_slave(auth_handler)	--启动login slave
		else
			launch_slave = nil
			conf.auth_handler = nil
			assert(conf.login_handler)
			assert(conf.command_handler)
			skynet.register(name)
			launch_master(conf)		--启动login master
		end
	end)
end

return login
