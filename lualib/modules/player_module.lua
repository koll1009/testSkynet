local NetApi=require "NetApi"
local skynet=require "skynet"
local PlayerData = require "pb.PlayerData_pb"
local player_data
local uid


local function playerdata_handle(data)
    logger.debug("recv create player data msg")
    player_data={}
    player_data.playerId=uid
    player_data.sex=data.sex
end

local function copy_player_data(a,b)
    a.playerId=tostring(b.playerId)
    a.sex=b.sex
    --a.hairColor=b.hairColor
   -- a.eyesColor=b.eyesColor
    --a.bodyColor=b.bodyColor
end

local funcs={}

funcs.sendPlayerData=function(p)    
    logger.debug("send player data :%s",tostring(p))
	local data=PlayerData()
    copy_player_data(data,p)
    NetApi.sendPlayerData(data)
end

function funcs.sync_PlayerData(des)
    skynet.send(des,"lua","sync_playerData",player_data)
end


function funcs._init(agent)
   --player_data={}
  -- local tmp=agent.playerdata
  -- copy_player_data(player_data,tmp)
   --funcs.sendPlayerData(player_data)
   uid=agent.uid
   NetApi.callback.PlayerData=playerdata_handle   
end

return funcs