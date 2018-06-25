
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.launch, ...
local memory = require "skynet.memory"

skynet.start(function()
	local sharestring = tonumber(skynet.getenv "sharestring" or 4096)
	memory.ssexpand(sharestring)

	local launcher = assert(skynet.launch("snlua","launcher"))
	skynet.name(".launcher", launcher)
	skynet.newservice "service_mgr"
	pcall(skynet.newservice,skynet.getenv "start" or "main","game",1)
	skynet.exit()
end)
