local fs = require "lfs"
local skynet=require "skynet"

local M = {}

local path=skynet.getenv "module_path"
local function init_modules(dir)
    local package_path=package.path
    package.path=package.path..";"..path.."/?.lua"
    for file in fs.dir(dir) do 
        if string.sub(file,1,1)~="." then 
            local ret=string.split(file,".")
            local file_name=ret[1]
            local funcs=require(file_name)
            table.merge(M,funcs)
        end
    end
    package.path=package_path
end 

init_modules(path)

return M