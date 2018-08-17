local path=...
local skynet = require "skynet"
local cjson=require "cjson"
local CMD = {}

local monster={}
local watchers={}

local function init_monster()
    local file=io.open(path,"r")
    local data=file:read("*a") 
    file:close()
    local monster_data=cjson.decode(data).SOList
    for _,m in ipairs(monster_data) do 
        local num=m.CreateNums
        for i=1,num do 
            local  monsterId=m.Id..i 
            monster[monsterId]=m
            skynet.send(".aoi","lua","Enter","m",{x=m.PosX,y=m.PosY,z=m.PosZ,o=45},monsterId)
        end
    end
end

local poffset=6

local function monsterAI()
    skynet.sleep(100)
    while true do 
       for mid,m in pairs(watchers) do
            local md=monster[mid]
            local x=math.floor(md.PosX)
            local z=math.floor(md.PosZ)
            local y=md.PosY
            x=math.random(x-poffset,x+poffset)+math.random()
            z=math.random(z-poffset,z+poffset)+math.random()

            for w,_ in pairs(m) do
                skynet.send(w,"lua","sync_monster",mid,monster[mid].TypeId,{x=x,y=y,z=z,o=45})
            end
       end
       skynet.sleep(100)
    end
end

function CMD.add_watcher(w,wposition,mposition,mid)

    if not watchers[mid] then 
        watchers[mid]={}
    end

    local ws=watchers[mid]
    if not ws[w] then 
        ws[w]=true
    end
    skynet.send(w,"lua","sync_monster",mid,monster[mid].TypeId,mposition)   
end   

function CMD.Leave(mid,w)
    local ws=watchers[mid]
    ws[w]=nil
end
    
    
skynet.start(function()
    math.randomseed(os.time())
    init_monster()
	skynet.dispatch("lua", function(session, source, command, ...)
		local f =CMD[command]
        if f then 
            f(...)
        end
    end)
    skynet.fork(monsterAI)
end)
