local skynet = require "skynet"
local queue = require "skynet.queue"
local snax = require "snax"
local netpack = require "netpack"
local logger=require "liblog"


local cs = queue()
local UID
local SUB_ID
local SECRET
local FD
local afktime = 0

local gate		-- 游戏服务器gate地址
local CMD = {}

local worker_co
local running = false

local timer_list = {}

--添加一个定时器事件
local function add_timer(id, interval, f)
	local timer_node = {}
	timer_node.id = id
	timer_node.interval = interval
	timer_node.callback = f
	timer_node.trigger_time = skynet.now() + interval

	timer_list[id] = timer_node
end

local function del_timer(id)
	timer_list[id] = nil
end

local function clear_timer()
	timer_list = {}
end

local function dispatch_timertask()
	local now = skynet.now()
	for k, v in pairs(timer_list) do
		if now >= v.trigger_time then
			v.callback()
			v.trigger_time = now + v.interval
		end
	end
end

local function worker()
	local t = skynet.now()
	while running do
		dispatch_timertask()
		local n = 100 + t - skynet.now()
		skynet.sleep(n)
		t = t + 100
	end
end

local agent
--当玩家通过login and game server双重认证后，会分配一个agent，并初始化
function CMD.init(source,conf)
	logger.debug("the agent inited for user %s",tostring(conf))
	agent=conf
end


function CMD.logout(source)

	logger.info("%s is logout", UID)
	logout()
end

function CMD.afk(source)

	afktime = skynet.time()
	--skynet.error(string.format("AFK"))
end

local function msg_unpack(msg, sz)
	logger.debug(type(msg))
	logger.debug(skynet.tostring(msg,sz))
	--[[ 
	local data = skynet.tostring(msg, sz)
	local netmsg = protobuf.decode("netmsg.NetMsg", data)

	if not netmsg then
		LOG_ERROR("msg_unpack error")
		error("msg_unpack error")
	end
	
	return netmsg
	--]]
end

local function msg_pack(data)
	local msg = protobuf.encode("netmsg.NetMsg", data)
	if not msg then
		LOG_ERROR("msg_pack error")
		error("msg_pack error")
	end
	return msg
end

local function msg_dispatch(netmsg)
	local begin = skynet.time()
	assert(#netmsg.name > 0)
	if netmsg.name == "netmsg.LogoutRequest" then
		return logout()
	end

	local name = netmsg.name
	LOG_INFO("calling to %s", name)
	local module, method = netmsg.name:match "([^.]*).(.*)"
	local data = {}
	local ok, obj = pcall(snax.uniqueservice, module)
	if not ok then
		LOG_ERROR(string.format("unknown module %s", module))
		return
	else
		pcall(obj.req[method], {
				name = name,
				payload = netmsg.payload,
				uid = UID,
				fd = FD
			}
		)
	end

	LOG_INFO("process %s time used %f ms", name, (skynet.time()-begin)*10)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,

	unpack = function (msg, sz)
		return msg_unpack(msg, sz)
	end,

	dispatch = function (_, _, netmsg)
		skynet.ret(msg_dispatch(netmsg))
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.retpack(cs(f, source, ...))
	end)
end)
