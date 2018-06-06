local mysql=require "libmysql"
local logger=require "liblog"
local skynet=require "skynet"
local runconf = require(skynet.getenv("runconfig"))local runconf = require(skynet.getenv("runconfig"))

local CMD={}
local db

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


skynet.start(function()
    skynet.dispatch("lua",function(session,source,cmd,...)
        local f = CMD[cmd]
        logger.debug("recev from %d",source)
		skynet.ret(skynet.pack(f(...)))
    end
    )
    --预留配置文件
    db=mysql.start(runconf.service.mysql.connection)
end
)
