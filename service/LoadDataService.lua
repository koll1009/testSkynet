local skynet =require "skynet"
local fs=require "lfs"
local builder=require "skynet.datasheet.builder"
local datasheet=require "skynet.datasheet"
local cjson=require "cjson"
local share=require "share"


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
                    builder.new(ret[1],t)
                    file:close()
                end
            end
        end
    end
end
 
skynet.start(function() 
    load("./mmo_data")--
    print(share.get())
    share.set(1)
end)