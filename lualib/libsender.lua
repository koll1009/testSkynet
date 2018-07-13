local socket = require "socket"
local cmd={}

local test


function cmd.SendRequest(type,bytes)
   -- assert(cmd.sockid)
    local data=string.pack("<I4",type)..bytes
    local package = string.pack(">s2", data)
    --socket.write(cmd.sockid, package)
    socket.write(test,package)
end

function cmd.SetSock(id)
  --  cmd.sockid=id
  test=id
end

return cmd