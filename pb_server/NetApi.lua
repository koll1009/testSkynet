--get pb module

--local packetsender = require "mmocore.packetsender"

local LoginData = require 'pb/LoginData_pb'
local OtherPlayerUpdateData = require 'pb/OtherPlayerUpdateData_pb'
local PlayerUpdateData=require "pb.PlayerUpdateData_pb"
local OtherPlayerUseSkill=require "pb.OtherPlayerUseSkill_pb"
local packetsender=require "libsender"

NetApi = {}

--client to server
function NetApi.sendOtherPlayerUpdateData(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10002, bytes)
end
 
function NetApi.sendOtherPlayerUseSkill(data)
	local bytes = data:SerializeToString()
	packetsender.SendRequest(10003, bytes)
end

--callback
NetApi.callback = {}
-- NetApi.callback.LoginData = nil
-- NetApi.callback.OtherPlayerUpdateData = nil
-- NetApi.callback.LoginData = nil
-- NetApi.callback.OtherPlayerUpdateData = nil
-- NetAp


local switch = {

    [2] = function(bytes)
		if NetApi.callback.OtherPlayerUpdateData ~= nil then 
			local data = OtherPlayerUpdateData()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUpdateData(data)
		end
	end,
	[3] = function(bytes)
		if NetApi.callback.OtherPlayerUseSkill ~= nil then 
			local data = OtherPlayerUseSkill()
			data:ParseFromString(bytes)
			NetApi.callback.OtherPlayerUseSkill(data)
		end
    end,
	 
    
}

--server to client
function NetApi.receiveMsg(msg)
	--local code, bytes = string.unpack("<I4z", msg)
	local code=string.unpack("<I4",msg)
	local bytes=string.sub(msg,5)
	--local _,a=string.unpack("<I4z", msg)
	
	--for i=1,#bytes do print(string.byte(bytes,i)) end
	--for i=1,#a do print(string.byte(a,i)) end
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
