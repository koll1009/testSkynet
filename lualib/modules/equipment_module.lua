local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerEquipment = require "pb.OtherPlayerEquipment_pb"
local player_equipment
local watchers
local uid
local funcs={}
local function player_equipment_handle(data)
    --logger.debug("recv equipment msg")
    local part=data.equipPart
    player_equipment[part]={equipId=data.equipId}
    for s,obj in pairs(watchers) do   
        print("no exccution")  
        funcs.sync_PlayerEquipment(s,uid)
   end      
end



funcs.sendOtherPlayerEquipment=function(uid,equipment)  
    local id=uid
    for _,e in pairs(equipment) do 
        --logger.debug(tostring(e))
        local data=OtherPlayerEquipment()
        data.playerId=id
        --data.equipType=e.equipType
        data.equipId=e.equipId
        NetApi.sendOtherPlayerEquipment(data)
    end
end

function funcs.sync_PlayerEquipment(t,uid)
    skynet.send(t,"lua","sync_PlayerEquipment",uid,player_equipment)
end

function funcs._close()
    player_equipment=nil
    watchers=nil
end

function funcs._init(agent)
    player_equipment={}
    watchers=agent.watchers
    uid=agent.uid
    NetApi.callback.OtherPlayerEquipment=player_equipment_handle
end

return funcs
