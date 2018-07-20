--local datasheet=require "skynet.datasheet"
local skynet=require "skynet"
local cmd={}
function cmd.get(key)
    return skynet.call(".ReadonlyLoadDataService","lua","get",key)
end

return cmd