local mysql = require "skynet.db.mysql"
local logger=require "liblog"

local mysqldb = {}
mysqldb.__index = mysqldb

--需要加状态标记，require库后未start 就调用sql接口

function mysqldb.start(conf)
    local host = conf.host
    local port = conf.port
    local database = conf.database
    local user = conf.user
    local password = conf.password

	local function on_connect(db)
		db:query("set charset utf8");
	end
	
	local db = mysql.connect({
		host = host,
		port = port,
		database = database,
		user = user,
		password = password,
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
		
        return nil
	end
	logger.debug("connect to myql susscced:database[%s]",database)
	local o = {db = db,connected=true}
	setmetatable(o, mysqldb)
    return o
end


local function build_selector(selector)
    local t = {}  

    if not selector then
       return "1=0" 
    end  

    for k, v in pairs(selector) do
        if type(k) == "string" then
            if type(v) == "string" then
                table.insert(t, string.format("%s = %s", k, mysql.quote_sql_str(v)))
            elseif type(v) == "number" then
                table.insert(t, string.format("%s = %d", k, v))
            end
        end
    end
    if next(t)==nil then --不许允无条件查询
        return "1=0"
    end

    local selector_str = table.concat(t," and ")
    return selector_str
end

local function build_fields(fields)
    if not fields then
        return "*"
    end

    local fileds_str = table.concat(fields, ",") 
    return fileds_str
end

 

function mysqldb:select(tablename, selector, fields)
    assert(self.connected,"pls connect mysql first")
    local db = self.db
	
    local selector_str = build_selector(selector," and ")
    local fields_str = build_fields(fields)

    local sql = string.format("select %s from %s where %s", fields_str, tablename, selector_str)
    logger.debug(sql)
    local ret = db:query(sql)

    if(ret.errno) then
        return ret.errno,ret.err
    end 

    return 0,ret

end

local function build_update(update)
    
    local t = {}  
    
    
    for k, v in pairs(update) do
        if type(k) == "string" then
            if type(v) == "string" then
                table.insert(t, string.format("%s = %s", k, mysql.quote_sql_str(v)))
            elseif type(v) == "number" then
                table.insert(t, string.format("%s = %d", k, v))
            end
        end
    end

    local  update_str = table.concat(t,",")
    return update_str
end

function mysqldb:update(tablename, selector, update)
    assert(self.connected,"pls connect mysql first")
    local db = self.db

    local selector_str = build_selector(selector)
    local update_str = build_update(update)

    local sql = string.format("update %s set %s where %s", tablename, update_str, selector_str)
    logger.debug(sql)
    local ret = db:query(sql)
    if(ret.errno) then
        return ret.errno,ret.err
    end 

    return 0,ret

end

local function build_insert_data(data)
    local field = {}
    local value = {}
    for k, v in pairs(data) do
        if type(k) == "string" then
            table.insert(field, k)
        end

        if type(v) == "string" then
            table.insert(value, string.format("%s", mysql.quote_sql_str(v)))
        elseif type(v) == "number" then
            table.insert(value, v)
        end
    end
    local field_str = table.concat(field, ",")
    local value_str = table.concat(value, ",")
    return field_str, value_str
end

 

function mysqldb:insert(tablename, data)
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    local field_str, value_str = build_insert_data(data)
    
    local sql = string.format("insert into %s(%s) values(%s)", tablename, field_str, value_str)
    logger.debug(sql)
    local ret = db:query(sql)
    
    if(ret.errno) then
        return ret.errno,ret.err
    end 

    return 0,ret
     
end

function mysqldb:delete(tablename, selector)
    assert(self.connected,"pls connect mysql first")
    local db = self.db
	
    local selector_str = build_selector(selector)
    local sql = string.format("delete from %s where %s", tablename, selector_str)
    local ret = db:query(sql)
    logger.debug(sql)
    if(ret.errno) then
        return ret.errno,ret.err
    end 

    return 0,ret
end

function mysqldb:executeSql(strSql)
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    local ret = db:query(strSql)
    if ret.errno then
        return ret.errno,ret.err
    end 

    return 0,ret
end

function mysqldb:beginTransaction()
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    local ret=db:query("start transaction;")
    logger.debug("start transaction;")
    if ret.errno then
        return ret.errno,ret.err
    end 

    return 0,ret
end

function mysqldb:commit()
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    local ret=db:query("commit;")
    logger.debug("commit;")
    if ret.errno then
        return ret.errno,ret.err
    end 

    return 0,ret
end

function mysqldb:rollback()
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    local ret=db:query("rollback;")
    logger.debug("rollback;")
    if ret.errno then
        return ret.errno,ret.err
    end 

    return 0,ret
end



function mysqldb:close()
    assert(self.connected,"pls connect mysql first")
    local db=self.db
    db:disconnect()
end

return mysqldb
