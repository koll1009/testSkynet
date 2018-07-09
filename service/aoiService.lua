local aoi=require "laoi"
local skynet=require "skynet"
local space
local CMD={}
local agent_id={} --agent aoiid表
local c_id={}     --aoiid character表
local aid=1
function CMD.close()
    if space then 
        aoi.release(space)
    end
end

function CMD.player_enter(source,mode,x,y,z)
    local id=agent_id[source]
    if not id then 
        id=aid
        agent_id[source]=id
        aid=aid+1
    else
        logger.warn("agent %08x call player enter repeatedly",source)
        return 
    end
    local c=c_id[id]
    if not c then 
        c={}
    else 

    end
    c.agent=source
    c.x=x
    c.y=y
    c.z=z
    c.mode=mode
    aoi.update(space,id,mode,x,y,z)
end

function CMD.player_leave(source)
   -- local id=agent_id[source]
   -- aoi.update(space,id,"d")


end

function CMD.update_position(source,x,y,z)
    assert(agent_id[source])
    local c=c_id[agent_id[source]]
    c.x=x
    c.y=y
    c.z=z
    aoi.update(agent_id[source],"",x,y,z)
end

local function cb_message(watcher,marker)
    
end

skynet.start(function() 
    space=aoi.create(cb_message)
    for i=1,10000 do
        aoi.update(space,i,"mw",i,i,i)
    end

    skynet.fork(function() 
        while true do 
            local ret=aoi.message(space)
            for _,v in ipairs(ret) do
               -- logger.debug("%d",v.w,v.m)
            end
            aoi.dump(space)
            logger.debug("%d:%d:%d",ret.num,ret.begin_time,ret.end_time)
            skynet.sleep(10)
        end
    end)
    skynet.fork(function() 
        math.randomseed(tostring(os.time()):reverse():sub(1, 7)) 
        while true do
            for i=1,10000 do
                local x,y,z=math.random(1,100),math.random(1,100),math.random(1,100)
                aoi.update(space,i,"mw",x,y,z)
            end
            skynet.sleep(10)
        end
    end)
    skynet.dispatch("lua",function(session,source,cmd,...)
        f=CMD[cmd]
        if f then 
            f(...)
        end
    end)

end)