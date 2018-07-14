local NetApi=require "NetApi"
local skynet=require "skynet"
local OtherPlayerUpdateData=require "pb.OtherPlayerUpdateData_pb"
local first=true

local function position_handle(data)
    --logger.debug("recv position pb data,position type is %s ",type(data.position))
    --测试数据 
    local position=data.position 
    if first then 
        skynet.send(".aoi","lua","player_enter","mw",{x=position.x,y=position.y,z=position.z,o=position.o})
        first=false 
    else
        skynet.send(".aoi","lua","update_position",{x=position.x,y=position.y,z=position.z,o=position.o})
    end
end
NetApi.callback.PlayerUpdateData=position_handle

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
funcs[30002]=send_position

return funcs
