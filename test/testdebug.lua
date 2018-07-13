local skynet =require "skynet"
local PlayerUpdateData = require 'pb/PlayerUpdateData_pb'


skynet.start(function() 
	local file=io.open("./3rd/protobuf/test.txt")
	local msg=file:read("*a")
	
	local data = PlayerUpdateData.PlayerUpdateData()
	 data:ParseFromString(msg)
	 print(data.position.x)

    skynet.exit()
end)
 

 