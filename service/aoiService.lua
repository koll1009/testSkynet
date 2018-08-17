local aoi=require "laoi"
local skynet=require "skynet"
local space
local CMD={}
local agent_id={} 
local c_id={}     
local aid=1

function CMD.Close()
    if space then 
        aoi.release(space)
    end
end


function CMD.Enter(source,mode,position,mid)
    if not mid then
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
    else
        logger.debug("a new monster enter")
        if not agent_id[source] then 
            agent_id[source]={}
        end
        agent_id[source][mid]=aid
        local c={}
        c.agent=source
        c.position=position
        c.mode=mode
        c.mid=mid
        c_id[aid]=c
        aoi.update(space,aid,mode,position.x,position.y,position.z)
        aid=aid+1
    end
end

function CMD.Leave(source,mid)
    if not mid then 
        logger.debug("player %08x leave aoi service",source)
        local id=agent_id[source]
        if id then
            aoi.update(space,id,"d")
            agent_id[source]=nil
            c_id[id]=nil
        end
    else 
        local m=agent_id[source]
        local id=m[mid]
        if id then
            aoi.update(space,id,"d")
            m[mid]=nil
            c_id[id]=nil
        end
    end
end

function CMD.Update(source,mode,position,mid)
    local id
    if mid then 
        id=agent_id[source][mid]
    else
        id=agent_id[source]
    end
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
        skynet.send(m.agent,"lua","add_watcher",w.agent,w.position,m.position,m.mid)
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