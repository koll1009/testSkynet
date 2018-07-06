local skynet =require "skynet"

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	pack = function(text) return text end,
	unpack = function(buf, sz) return skynet.tostring(buf,sz) end,
}

skynet.start(function() 
    skynet.call(".aoi","text","update wm ")
    skynet.exit()
end)
 

 