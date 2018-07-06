local aoi=require "laoi"
local skynet=require "skynet"
local space
local CMD={}
local map={}
local aid=1
function CMD.close()
    if space then 
        aoi.release(space)
    end
end

function CMD.update(source,mode,x,y,z)
    local id=map[source]
    if not id then 
        id=aid
        map[source]=id
        aid=aid+1
    end
    aoi.update(space,id,mode,x,y,z)
end

skynet.start(function() 
    space=aoi.create()
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