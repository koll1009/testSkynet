local index=...
local logger=require "liblog"
local skynet=require "skynet"
local runconf = require(skynet.getenv("runconfig"))
local mysql=require "libmysql"

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end
local function pr(ret,res)
    logger.debug("%s:%s",ret==0 and true or false,ret==0 and dump(res) or res)
end

skynet.register_protocol{name="client",id=skynet.PTYPE_CLIENT}

skynet.start(function()
    logger.debug(" service testmysql start!")
    db=mysql.start(runconf.service.mysql.connection)
    pr(db:beginTransaction())
    pr(db:executeSql("update table1 set age=01 where id=66"))
    --pr(db:rollback())
    pr(db:commit())
    db:close()

   -- pr(db:executeSql("update table1 set age=26 where id=66"))
    --pr(skynet.call(".mysqlpool","lua","execute","select * from table1"))
    
    --pr(skynet.call(".mysqlpool","lua","execute","update test.table1 set age=26 where id=66"))
    --pr(skynet.call(".mysqlpool","lua","execute","insert into table1(name,age) values('koll',31)"))

    --pr( skynet.call(".dbpool","lua","select","table1",{id=1},{"id","name"}))
   -- skynet.call(".mysqlService1","lua","select","table1",{id=1},{"id","name"})
   -- pr( skynet.call(".mysqlpool","lua","select","table1",{id=1},{"id","name"}))
    --skynet.send(".mysqlpool","lua","select","table1",{id=1},{"id","name"})
    --[[ 
    for k=1,10  do
    for i=1,20 do 
      --  pr(skynet.call(".mysqlpool","lua","select","table1",{id=66},{"id","name"}))
      --print("testmyql",index)
      skynet.send(".mysqlpool","lua","select","table1",{id=66},{"id","name"})
      --skynet.call(".mysqlpool","lua","select","table1",{id=66},{"id","name"})
    end
    skynet.sleep(200)
    skynet.rawsend(".mysqlpool","client",skynet.pack("count"))
end
   -- local ret=skynet.call(".mysqlpool","lua","select","table1",{id=1},{"id","name"})
    --pr(ret)
   
    --[[ 
    
    pr(skynet.unpack(skynet.rawcall(".dbpool" ,"lua",skynet.pack("select","table1",{id=1},{"id","name"})))
    pr(skynet.unpack(skynet.rawcall(".dbpool" ,"lua",skynet.pack("update","table1",{id=1},{name="koll1009"}))))
    pr(skynet.unpack(skynet.rawcall(".dbpool" ,"lua",skynet.pack("insert","table1",{name="leidanling",age=33}))))
    pr(skynet.unpack(skynet.rawcall(".dbpool" ,"lua",skynet.pack("delete","table1",{id=1}))))
    pr(skynet.unpack(skynet.rawcall(".dbpool" ,"lua",skynet.pack("select","table1",{id=1},{"id","name"}))))
   --]]
 
   
    skynet.exit()
end
)