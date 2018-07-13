local NetApi=require "NetApi"
local skynet=require "skynet"
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