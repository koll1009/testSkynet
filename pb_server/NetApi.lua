--get pb module

--local packetsender = require "mmocore.packetsender"

local LoginData = require 'pb/LoginData_pb'
local OtherPlayerUpdateData = require 'pb/OtherPlayerUpdateData_pb'

NetApi = {}

--client to server
function NetApi.sendPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	--packetsender.SendRequest(10001, bytes)
end
function NetApi.sendLoginData(data)
	local bytes = data:SerializeToString()
	--packetsender.SendRequest(30001, bytes)
end
function NetApi.sendPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	--packetsender.SendRequest(30002, bytes)
end

--callback
NetApi.callback = {}
-- NetApi.callback.LoginData = nil
-- NetApi.callback.OtherPlayerUpdateData = nil
-- NetApi.callback.LoginData = nil
-- NetApi.callback.OtherPlayerUpdateData = nil


local switch = {
	[1] = function(bytes)
		if NetApi.callback.LoginData ~= nil then 
			local data = LoginData()
			data:ParseFromString(bytes)
			NetApi.callback.LoginData(data)
		end
    end,
    [2] = function(bytes)
		if NetApi.callback.OtherPlayerUpdateData ~= nil then 
			local data = OtherPlayerUpdateData()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUpdateData(data)
		end
    end,
    [20001] = function(bytes)
		if NetApi.callback.LoginData ~= nil then 
			local data = LoginData()
			data:ParseFromString(bytes)
			NetApi.callback.LoginData(data)
		end
    end,
    [20002] = function(bytes)
		if NetApi.callback.OtherPlayerUpdateData ~= nil then 
			local data = OtherPlayerUpdateData()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUpdateData(data)
		end
    end,
    
}

--server to client
function NetApi.receiveMsg(msg)
	local code, bytes = string.unpack("<I4z", msg)
	print(code,bytes)
	-- print("NetApi.receiveMsg", code, bytes)
	NetApi.receiveProtoPacket(code, bytes)
end

function NetApi.receiveProtoPacket(packCode, bytes)
	local cb = switch[packCode]
	if cb ~= nil then
		cb(bytes)
	end
end

return NetApi
