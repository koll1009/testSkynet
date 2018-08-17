-- AutoGen DO NOT EDIT

local packetsender = require "libsender"
local LoginData = require "pb.LoginData_pb"
local MonsterData = require "pb.MonsterData_pb"
local OtherPlayerEquipment = require "pb.OtherPlayerEquipment_pb"
local OtherPlayerUpdateData = require "pb.OtherPlayerUpdateData_pb"
local OtherPlayerUseSkill = require "pb.OtherPlayerUseSkill_pb"
local PlayerData = require "pb.PlayerData_pb"
local LoginData = require "pb.LoginData_pb"
local OtherPlayerUpdateData = require "pb.OtherPlayerUpdateData_pb"


local NetApi = {}

 

--client to server
function NetApi.sendLoginData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10001, bytes)
end
function NetApi.sendMonsterData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10002, bytes)
end
function NetApi.sendOtherPlayerEquipment(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10003, bytes)
end
function NetApi.sendOtherPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10004, bytes)
end
function NetApi.sendOtherPlayerUseSkill(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10005, bytes)
end
function NetApi.sendPlayerData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10006, bytes)
end
function NetApi.sendPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10007, bytes)
end
function NetApi.sendLoginData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(30001, bytes)
end
function NetApi.sendPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(30002, bytes)
end


--callback
NetApi.callback = {}
-- NetApi.callback.LoginData = nil
-- NetApi.callback.MonsterData = nil
-- NetApi.callback.OtherPlayerEquipment = nil
-- NetApi.callback.OtherPlayerUpdateData = nil
-- NetApi.callback.OtherPlayerUseSkill = nil
-- NetApi.callback.PlayerData = nil
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
		if NetApi.callback.MonsterData ~= nil then 
			local data = MonsterData()
			data:ParseFromString(bytes)
			NetApi.callback.MonsterData(data)
		end
    end,
    [3] = function(bytes)
		if NetApi.callback.OtherPlayerEquipment ~= nil then 
			local data = OtherPlayerEquipment()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerEquipment(data)
		end
    end,
    [4] = function(bytes)
		if NetApi.callback.OtherPlayerUpdateData ~= nil then 
			local data = OtherPlayerUpdateData()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUpdateData(data)
		end
    end,
    [5] = function(bytes)
		if NetApi.callback.OtherPlayerUseSkill ~= nil then 
			local data = OtherPlayerUseSkill()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUseSkill(data)
		end
    end,
    [6] = function(bytes)
		if NetApi.callback.PlayerData ~= nil then 
			local data = PlayerData()
			data:ParseFromString(bytes)
			NetApi.callback.PlayerData(data)
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
	local code = string.unpack("<I4", msg)
	local bytes=string.sub(msg,5)
	NetApi.receiveProtoPacket(code, bytes)
end

function NetApi.receiveProtoPacket(packCode, bytes)
	local cb = switch[packCode]
	if cb ~= nil then
		cb(bytes)
	end
end

return NetApi
