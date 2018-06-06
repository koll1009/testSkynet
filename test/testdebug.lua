local skynet = require "skynet"
local socket = require "skynet.socket"
local logger=require"liblog"

skynet.call(".service","lua")