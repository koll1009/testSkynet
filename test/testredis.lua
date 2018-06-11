local skynet = require "skynet"
local dump=require "libdump"
local logger=require "liblog"

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
}

local function pr(ret,res)
    logger.debug("%s:%s",ret,ret and dump.dump(res) or res)
end

skynet.start(function()    
    pr(skynet.call(".redis","lua","set","A","hello"))
    pr(skynet.call(".redis","lua","set","B","world"))
    pr(skynet.call(".redis","lua","sadd","C","one"))
    pr(skynet.call(".redis","lua","get","A"))
    pr(skynet.call(".redis","lua","get","B"))
    pr(skynet.call(".redis","lua","del","D"))

    --[[ 
	db:del "C"
	db:set("A", "hello")
	db:set("B", "world")
	db:sadd("C", "one")

	print(db:get("A"))
	print(db:get("B"))

	db:del "D"
	for i=1,10 do
		db:hset("D",i,i)
	end
	local r = db:hvals "D"
	for k,v in pairs(r) do
		print(k,v)
	end

	db:multi()
	db:get "A"
	db:get "B"
	local t = db:exec()
	for k,v in ipairs(t) do
		print("Exec", v)
	end

	print(db:exists "A")
	print(db:get "A")
	print(db:set("A","hello world"))
	print(db:get("A"))
	print(db:sismember("C","one"))
	print(db:sismember("C","two"))

	print("===========publish============")

	for i=1,10 do
		db:publish("foo", i)
	end
	for i=11,20 do
		db:publish("hello.foo", i)
	end

    db:disconnect()
    --]]
	skynet.exit()
end)