local socket = require "socket"
local cmd={}

local socketID


function cmd.SendRequest(type,bytes)
    local data=string.pack("<I4",type)..bytes
    local package = string.pack(">s2", data)
    socket.write(socketID,package)
end

function cmd.SetSock(id)
  socketID=id
end

return cmd