local fs = require "lfs"
local skynet=require "skynet"

local M = {}
M.init_array={}
M.close_array={}

function M.load_modules(dir)
    local package_path=package.path
    package.path=package.path..";"..dir.."/?.lua"
    for file in fs.dir(dir) do 
        if string.sub(file,1,1)~="." then 
            local ret=string.split(file,".")
            local file_name=ret[1]
            local funcs=require(file_name)
            assert(type(funcs)=="table")
            if funcs._init then 
                table.insert(M.init_array,funcs._init)
            end
            if funcs._close then 
                table.insert(M.close_array,funcs._close)
            end
            table.merge(M,funcs)
        end
    end
    package.path=package_path
end 
function M.init(agent)
    for _,func in ipairs(M.init_array) do
        func(agent)
    end
end
function M.close()
    for _,func in ipairs(M.close_array) do
        func()
    end
    M.init_array={}
    M.close_array={}
end

return M