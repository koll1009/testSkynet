local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUseSkill=require "pb.OtherPlayerUseSkill_pb"
local watchers
local function skill_handle(data)
  
    local playerid=data.playerId
    local skillid=data.skillId
    local targetid=data.targetId
    print("recv skill",playerid,skillid,targetid)
    for s,obj in pairs(watchers) do       
        skynet.send(s,"lua","sync_skill",playerid,targetid,skillid)
   end      
end
NetApi.callback.OtherPlayerUseSkill=skill_handle

local funcs={}
funcs.sendOtherPlayerUseSkill=function(sid,tid,skid)
    local data=OtherPlayerUseSkill()
	data.playerId=sid
    data.targetId=tid 	
    data.skillId=skid
    NetApi.sendOtherPlayerUseSkill(data)
end
function funcs._close()
   watchers=nil  
end

function funcs._init(w,u)
    watchers=w
end
return funcs