local NetApi=require "NetApi"
local skynet=require "skynet"
local first=true
local function position_handle(data)
    --logger.debug("recv position pb data,id is %d,position type is %s ",data.playerid,type(data.position))
   -- logger.debug("recv position pb data,position   is %s ",data)
    --测试数据 
    local ret=string.split(data,":")
    if first then 
        skynet.send(".aoi","lua","player_enter","mw",{x=ret[1],y=ret[2],z=ret[3],o=ret[4]})
        first=false 
    else
        skynet.send(".aoi","lua","update_position",{x=ret[1],y=ret[2],z=ret[3],o=ret[4]})
    end
end
NetApi.callback.OtherPlayerUpdateData=position_handle