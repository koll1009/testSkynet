local aoi=require "laoi"
local skynet=require "skynet"
local space
local CMD={}
local agent_id={} 
local c_id={}     
local aid=1

function CMD.close()
    if space then 
        aoi.release(space)
    end
end


function CMD.player_enter(source,mode,position)
    logger.debug("a new player %08x enter aoi service,data is %s",source,tostring(position))
    local id=agent_id[source]
    if not id then 
        id=aid
        agent_id[source]=id
        aid=aid+1
    else
        logger.warn("agent %08x call player enter aoi service repeatedly",source)
        return 
    end
    local c=c_id[id]
    if not c then 
        c={}
    else 
        logger.warn("agent %08x call player enter aoi service repeatedly",source)
        return 
    end
    c.agent=source
    c.position=position
    c.mode=mode
    c_id[id]=c
    aoi.update(space,id,mode,position.x,position.y,position.z)
   
end

function CMD.player_leave(source)
   logger.debug("player %08x leave aoi service",source)
   local id=agent_id[source]
   if id then
    aoi.update(space,id,"d")
     agent_id[source]=nil
     c_id[id]=nil
   end
end

function CMD.update_position(source,mode,position)
    --logger.debug("player %08x upate position,data is %s",source,tostring(position))
    local id=agent_id[source]
    if not id then 
        logger.error("uninitialized agent %08x  calls position-update",source)
        return 
    end
    local c=c_id[id]
    c.position=position
    c.mode=mode
    aoi.update(space,id,mode,position.x,position.y,position.z)
end


local function cb_message(watcher,marker)
    local m=c_id[marker]
    local w=c_id[watcher] 
    if w and m then  
        skynet.send(m.agent,"lua","add_watcher",w.agent,w.position,m.position)
    else
        logger.error("illegal aoi id ,watcher: %d and marker: %d",watcher,marker)
    end
end


skynet.start(function() 
    space=aoi.create(cb_message)
    skynet.dispatch("lua",function(session,source,cmd,...)
        f=CMD[cmd]
        if f then 
            skynet.retpack(f(source,...))
        end
    end)

    skynet.fork(function() 
        while true do 
            aoi.message(space)
           -- aoi.dump(space)
            skynet.sleep(10)
        end
    end)

end) 