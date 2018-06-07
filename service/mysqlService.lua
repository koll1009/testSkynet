local mysql=require "libmysql"
local logger=require "liblog"
local skynet=require "skynet"
local runconf = require(skynet.getenv("runconfig"))local runconf = require(skynet.getenv("runconfig"))

local CMD={}
local db

local servicename,index=...

function CMD.select(tablename,selector,fields)
    return db:select(tablename,selector,fields)
end

function CMD.insert(tablename,data)
    return db:insert(tablename,data)
end

function CMD.update(tablename, selector, update)
    return db:update(tablename,selector,update)
end

function CMD.delete(tablename,selector)
    return db:delete(tablename,selector)
end

skynet.register_protocol{
    name="client",
    id=skynet.PTYPE_CLIENT,
    pack=skynet.pack,
    unpack=skynet.unpack
}

skynet.start(function()
    logger.set_name(servicename..index)
    skynet.dispatch("lua",function(session,source,cmd,...)
        local f = CMD[cmd]
        --logger.debug("recev from %08x",source)
        skynet.ret(skynet.pack(f(...)))
        skynet.send(".dbpool","client","back",index)
    end
    )

    db=mysql.start(runconf.service.mysql.connection)
end
)
