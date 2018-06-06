local skynet = require "skynet"
local socket = require "skynet.socket"
local logger=require"liblog"

local function split_cmdline(cmdline)
	local split = {}
	for i in string.gmatch(cmdline, "%S+") do
		table.insert(split,i)
	end
	return split
end

local function console_main_loop()
	local stdin = socket.stdin()
	while true do
		local cmdline = socket.readline(stdin, "\n")
		local split = split_cmdline(cmdline)
        for _,v in ipairs(split) do
			logger.debug("type:%s;value:%s",type(v),v)
        end
        
	end
end

skynet.start(function()
	skynet.fork(console_main_loop)
end)