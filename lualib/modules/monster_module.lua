local NetApi=require "NetApi"
local skynet=require "skynet"
local MonsterData = require "pb.MonsterData_pb"
local pos
local monster

local function distance(p1,p2)
    return  (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y)+(p1.z-p2.z)*(p1.z-p2.z)  
end
local funcs={}

 
funcs.sendMonsterData=function(source,mid,type,position)    
    if distance(pos,position)>400 then 
        skynet.send(source,"lua","Leave",mid,skynet.self())
        monster[mid]=nil
    else
        if not monster[mid] then
            monster[mid]=source
        end
        local data=MonsterData()
        data.monsterId=mid
        data.monsterType=type
        data.pos.x=position.x
        data.pos.y=position.y
        data.pos.z=position.z
        data.pos.o=position.o
        NetApi.sendMonsterData(data)
	end
end

function funcs._init(agent)
    pos=agent.position
    monster={}
end
function funcs._close()
    for m,s in pairs(monster) do 
        skynet.send(s,"lua","Leave",m,skynet.self())
    end
end

return funcs