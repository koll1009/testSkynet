local skynet =require "skynet"
local fs=require "lfs"
local cjson=require "cjson"

local datas={}
local CMD={}
local function load(path)
    for file in fs.dir(path) do
        if string.sub(file, 1, 1) ~= "." then
            local f = path .. "/" .. file
            local attr = fs.attributes(f)
            if attr.mode == "directory" then
                load(f)
            else
                local ret=string.split(file,".") 
                if ret[2] and ret[2]=="json" then 
                    local file=io.open(f,"r")
                    local str_json=file:read("a")
                    local t=cjson.decode(str_json)
                    if datas[ret[1]] then 
                        logger.warn("repeated load data from %s",f)
                    end
                    datas[ret[1]]=t
                    file:close()
                end
            end
        end
    end
end

function CMD.get(key)
    local t=datas[key]
    if t then 
        if t[key] then 
            return t[key]
        else 
            return t
        end
    else
        logger.error("error key %s",key)
    end
end
 
skynet.start(function() 
    load("./mmo_data")
    skynet.dispatch("lua",function(session,source,cmd,...)
        
        local f=CMD[cmd]
        if f then 
            skynet.retpack(f(...))
        end
    end)
end)