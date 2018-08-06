local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUpdateData=require "pb.OtherPlayerUpdateData_pb"
local first=true
local watchers
local uid

local function distance(p1,p2)
    return  (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y)+(p1.z-p2.z)*(p1.z-p2.z)  
end

local function position_handle(data)
    local position=data.position 
    local x,y,z,o=position.x,position.y,position.z,position.o
    if first then 
        skynet.send(".aoi","lua","player_enter","mw",{x=x,y=y,z=z,o=o})
        first=false 
    else
        skynet.send(".aoi","lua","update_position","mw",{x=x,y=y,z=z,o=o})
        for s,obj in pairs(watchers) do
             if distance(obj,position)>400 then
                watchers[s]=nil
             else
                skynet.send(s,"lua","sync_position",uid,x,y,z,o)
             end
        end      

    end 
end
NetApi.callback.OtherPlayerUpdateData=position_handle

local function send_position(uid,x,y,z,o)    
	local data=OtherPlayerUpdateData()
    data.playerId=tonumber(uid)
    data.position.x=x
    data.position.y=y 
	data.position.z=z
	data.position.o=o 
    NetApi.sendOtherPlayerUpdateData(data)
end

local funcs={}

funcs.sendOtherPlayerUpdateData=function(uid,x,y,z,o)    
	local data=OtherPlayerUpdateData()
    data.playerId=tonumber(uid)
    data.position.x=x
    data.position.y=y 
	data.position.z=z
	data.position.o=o 
    NetApi.sendOtherPlayerUpdateData(data)
end

function funcs._close()
    first=true
    for s,obj in pairs(watchers) do
        skynet.send(s,"lua","sync_position",uid,0,0,0,0)
   end   
   uid=nil 
   watchers=nil   
end

function funcs._init(w,u)
    watchers=w
    uid=u
end

return funcs
