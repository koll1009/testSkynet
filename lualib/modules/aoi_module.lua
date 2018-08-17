local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUpdateData=require "pb.OtherPlayerUpdateData_pb"
local first=true
local watchers
local uid
local pos

local function distance(p1,p2)
    return  (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y)+(p1.z-p2.z)*(p1.z-p2.z)  
end

local function position_handle(data)
    --logger.debug("recv aoi msg")
    local position=data.position 
    pos.x=position.x
    pos.y=position.y
    pos.z=position.z
    pos.o=position.o
    if first then 
        skynet.send(".aoi","lua","Enter","mw",pos)
        first=false 
    else
        skynet.send(".aoi","lua","Update","mw",pos)
        for s,obj in pairs(watchers) do
             if distance(obj,position)>400 then
                watchers[s]=nil
             else
                skynet.send(s,"lua","sync_position",uid,pos)
             end
        end      

    end 
end

 
local funcs={}

function funcs.sync_OtherPlayerUpdateData()
    
end

funcs.sendOtherPlayerUpdateData=function(uid,pos)    
	local data=OtherPlayerUpdateData()
    data.playerId=uid
    data.position.x=pos.x
    data.position.y=pos.y 
	data.position.z=pos.z
	data.position.o=pos.o 
    NetApi.sendOtherPlayerUpdateData(data)
end

function funcs._close()
    first=true
    for s,obj in pairs(watchers) do
        skynet.send(s,"lua","sync_position",uid,{x=0,y=0,z=0,o=0})
    end   
    uid=nil 
    watchers=nil   
end

function funcs._init(agent)
    watchers=agent.watchers
    uid=agent.uid
    agent.position={}
    pos=agent.position
    NetApi.callback.OtherPlayerUpdateData=position_handle
end

return funcs
