local skynet = require "skynet"
local logger = require "liblog"

local runconf = require(skynet.getenv("runconfig"))

local maxnum = runconf.service.mysql.maxnum
local mysqlName=runconf.service.mysql.servicename
local dbpool = {}
local CMD={}

local function init()
    for i = 1, maxnum do
        dbpool[i] = string.format(".%s%d",mysqlName, i) 
    end
    
end

local next_id = 0
local function next_connection()
    local id=next_id%maxnum+1
    next_id = next_id + 1
    logger.debug(" redirect to next %s ",dbpool[id])
    return dbpool[id],id
end

local function fetch_connection(key)
    if type(key) == "number" then
        logger.debug(" redirect to fetch %s ",dbpool[key])
        return dbpool[key]
    else
        return next_connection()
    end
end

function CMD.select(tablename,selector,fields)
    local conn=fetch_connection(CMD.tindex)
    return skynet.call(conn,"lua","select",tablename,selector,fields)
end

function CMD.insert(tablename,data)
    local conn=fetch_connection(CMD.tindex)
    return skynet.call(conn,"lua","insert",tablename,data)
end

function CMD.update(tablename, selector, update)
    local conn=fetch_connection(CMD.tindex)
    return skynet.call(conn,"lua","update",tablename,selector,update)
end

function CMD.delete(tablename,selector)
    local conn=fetch_connection(CMD.tindex)
    return skynet.call(conn,"lua","delete",tablename,selector)
end

function CMD.execute(strSql)
    local conn=fetch_connection(CMD.tindex)
    return skynet.call(conn,"lua","execute",strSql)
end

function CMD.beginTransaction()
    local conn,id=next_connection()
    CMD.tindex=id
    return skynet.call(conn,"lua","beginTransaction")
end

function CMD.commit()
    local conn=fetch_connection(CMD.tindex)
    CMD.tindex=nil
    return skynet.call(conn,"lua","commit")
end

function CMD.rollback()
    local conn=fetch_connection(CMD.tindex)
    CMD.tindex=nil 
    return skynet.call(conn,"lua","rollback")
end

init()

return CMD