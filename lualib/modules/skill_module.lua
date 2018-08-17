local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUseSkill=require "pb.OtherPlayerUseSkill_pb"
local watchers
local function skill_handle(data)
    --logger.debug("recv skill msg")
    local playerid=data.playerId
    local skillid=data.skillId
    local targetid=data.targetId
    
    for s,obj in pairs(watchers) do       
        skynet.send(s,"lua","sync_skill",playerid,targetid,skillid)
   end      
end


local funcs={}
funcs.sendOtherPlayerUseSkill=function(sid,tid,skid)
    local data=OtherPlayerUseSkill()
	data.playerId=sid
    data.targetId=tid 	
    data.skillId=skid
    NetApi.sendOtherPlayerUseSkill(data)
end


function funcs._init(agent)
    watchers=agent.watchers
    NetApi.callback.OtherPlayerUseSkill=skill_handle
end

return funcs