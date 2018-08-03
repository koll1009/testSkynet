local aoi=require "laoi"
local skynet=require "skynet"
local space
local CMD={}
local agent_id={} --agent aoiid表
local c_id={}     --aoiid character表
local aid=1
local npc={}

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
    local x,y,z=position.x,position.y,position.z
    c.agent=source
    c.x= x
    c.y= y
    c.z= z
    c.o=position.o 
    c.mode=mode
    c_id[id]=c
    aoi.update(space,id,mode,x,y,z)
   
end

function CMD.test(source,sid,tid,skid)
    local id=agent_id[source]
    local c=c_id[id]
    local radius_objs=c.radius_objs
    if radius_objs~=nil then
       
        for id,_ in pairs(radius_objs) do   
            local m=c_id[id]
            if m==nil then 
                radius_objs[id]=nil
            else                             
                skynet.send(m.agent,"lua","test",sid,tid,skid)   
            end
        end
        
    end 
end

function CMD.player_leave(source)
   logger.debug("player %08x leave",source)
   local id=agent_id[source]
   if id then
    aoi.update(space,id,"d")
     
    local radius_objs=c_id[id].radius_objs
    if radius_objs~=nil then      
        for id,_ in pairs(radius_objs) do  
            local m=c_id[id]
            if m==nil then 
                radius_objs[id]=nil
            else                             
                skynet.send(m.agent,"lua","async_aoi",source,0,0,0,0)
            end
        end      
    end 

     agent_id[source]=nil
     c_id[id]=nil
   end
end

function CMD.update_position(source,position)
    --logger.debug("player %08x upate position,data is %s",source,tostring(position))
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
    local radius_objs=c.radius_objs
    if radius_objs~=nil then
       
        for id,_ in pairs(radius_objs) do   
            local m=c_id[id]
            if m==nil then 
                radius_objs[id]=nil
            else
                local test=((m.x-x)*(m.x-x)+(m.y-y)*(m.y-y)+(m.z-z)*(m.z-z))
                if test>400 then 
                    radius_objs[id]=nil
                else                    
                    skynet.send(m.agent,"lua","async_aoi",source,x,y,z,position.o)
                end
               -- logger.debug("distance is %f\n",test)     
            end
        end
        
    end 
end

--watcher marker分别为aoi服务中的id
local function cb_message(watcher,marker)
    local c=c_id[marker] --or npc[marker]
    local w=c_id[watcher] 
    if w and c then 
        if  c.radius_objs==nil then 
            c.radius_objs={}
        end
        c.radius_objs[watcher]=true 
        skynet.send(w.agent,"lua","async_aoi",c.agent,c.x,c.y,c.z,c.o)
    else
        logger.error("illegal aoi id ,watcher: %d and marker: %d",source,watcher,marker)
    end
end

local function testNPC()
    for i=10000,10500 do
        local c={}
        local x,y,z,o=math.random(1,100),math.random(1,100),0,45
        c.agent=true
        c.x= x
        c.y= y
        c.z= z
        c.o=o 
        c.mode="m"
        aoi.update(space,aid,"m",x,y,z)
       --aoi.update(space,aid,"m",-116,3,38)
        npc[aid]=c
        aid=aid+1
    end
end 

skynet.start(function() 
    space=aoi.create(cb_message)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7)) 
    --testNPC()

     
    --[[
    skynet.fork(function() 
        
        while true do
            for aid,c in ipairs(npc) do 
                if math.random(1,1024)>(1024>>1) then 
                    if c.x<100 then 
                        c.x=c.x+1
                    end 
                else 
                    if c.x>0 then 
                        c.x=c.x-1
                    end
                end
                if math.random(1,1024)>(1024>>1) then 
                    if c.y<100 then 
                        c.y=c.y+1
                    end 
                else 
                    if c.y>0 then 
                        c.y=c.y-1
                    end
                end
                --aoi.update(space,aid,"m",c.x,c.y,c.z)
            end            
            skynet.sleep(100)
        end
    end)
--]]
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