local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUseSkill=require "pb.OtherPlayerUseSkill_pb"

local function skill_handle(data)

    local playerid=data.playerId
    local skillid=data.skillId
    local targetid=data.targetId
    skynet.send(".aoi","lua","test",playerid,targetid,skillid)
end
NetApi.callback.OtherPlayerUseSkill=skill_handle

local funcs={}
funcs.sendOtherPlayerUseSkill=function(sid,tid,skid)
    local data=OtherPlayerUseSkill()
	data.playerId=sid
    data.skillId=skid
	data.targetId=tid 	
    NetApi.sendOtherPlayerUseSkill(data)
end
return funcs