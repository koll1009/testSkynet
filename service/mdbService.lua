local skynet=require "skynet"
local minite=1
local time_list={}
local CMD={}
local minute_hand=11

local db={}

function CMD.GET(key)
	return db[key]
end

function CMD.SET(key, value)
	local last = db[key]
	db[key] = value
	return last
end

local function add_timer(func,interval)
    assert(interval>0 and interval<256)
    local expire=minute_hand+interval
    expire=(expire&0xff)+1
    if time_list[expire]==null then
        time_list[expire]={}
    end
    table.insert(time_list[expire],func)

end

local function tick()
    local t=time_list[(minute_hand&0xff)+1]
    if not t or table.empty(t) then 
        return 
    end
    for k,f in ipairs(t) do
        f.f(f.key,k)
        t[k]=nil
    end
end

skynet.start(function() 
    skynet.dispatch("lua",function(session,souce,cmd,...)
        local f=CMD[cmd]
        if f then 
            skynet.retpack(f(...))
        end
    end)
    
    for i=1,50 do 
        add_timer({key=i,f=print},i)
    end
    skynet.fork(function() 
        local i=0
        logger.info("timer is null，mh is %d",minute_hand)
        while(i<523) do
           
            skynet.sleep(1)
         
            tick()    
            if i>0 and i%50==0 then
                logger.info("timer is null，mh is %d",minute_hand)
                for i=1,50 do 
                    add_timer({key=i,f=print},i)
                end
            end
            minute_hand=minute_hand+1
            i=i+1
        end 
    end)
end)
