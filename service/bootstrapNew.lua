local skynet = require "skynet"
require "skynet.manager"	-- import skynet.launch, ...
local memory = require "skynet.memory"

skynet.start(function()
	local sharestring = tonumber(skynet.getenv "sharestring" or 4096)
	memory.ssexpand(sharestring)

	local launcher = assert(skynet.launch("snlua","launcher"))
	skynet.name(".launcher", launcher)
 
	pcall(skynet.newservice,skynet.getenv "start" or "main")
	skynet.exit()
end)
