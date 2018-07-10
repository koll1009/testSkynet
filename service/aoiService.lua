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

function CMD.player_enter(source,mode,position)
    logger.debug("a new player %08x enter,data is %s",source,tostring(position))
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
        logger.warn("agent %08x call player enter repeatedly",source)
        return 
    end
    local x,y,z=position.x,position.y,position.x
    c.agent=source
    c.x= x
    c.y= y
    c.z= z
    c.o=position.o 
    c.mode=mode
    c_id[id]=c
    aoi.update(space,id,mode,x,y,z)
   
end

function CMD.player_leave(source)
   local id=agent_id[source]
   aoi.update(space,id,"d")
   agent_id[source]=nil
   c_id[id]=nil
end

function CMD.update_position(source,position)
    local id=agent_id[source]
    if not id then 
        logger.error("agent %08x uninitialized call update position",source)
        return 
    end
    local c=c_id[id]
    local x,y,z=position.x,position.y,position.z
    c.x=x
    c.y=y
    c.z=z
    c.o=position.o
   
    aoi.update(space,id,"mw",x,y,z)
end

--watcher marker分别为aoi服务中的id
local function cb_message(watcher,marker)
    --logger.error(" aoi  ........................... ")
   -- local c=c_id[marker]
    --local w=c_id[watcher]
    --if w and c then 
       -- skynet.send(w.agent,"lua","async_aoi",c.agent,c.x,c.y,c.z,c.o)
   -- else
       -- logger.error("illegal aoi id ,watcher: %d and marker: %d",source,watcher,marker)
   -- end
end

skynet.start(function() 
    space=aoi.create(cb_message)
    --[[
    for i=1,10000 do
        aoi.update(space,i,"mw",i,i,i)
    end

  
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
    --]]
    skynet.dispatch("lua",function(session,source,cmd,...)
        --logger.debug(cmd..type(CMD[cmd]))
        f=CMD[cmd]
        if f then 
            f(source,...)
        end
    end)

    skynet.fork(function() 
        while true do 
         print( aoi.message(space) )
           -- aoi.dump(space)
            skynet.sleep(100)
        end
    end)

end)