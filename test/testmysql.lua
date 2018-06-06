
local logger=require "liblog"
local skynet=require "skynet"
local runconf = require(skynet.getenv("runconfig"))

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

skynet.start(function()
    logger.debug(" service testmysql start!")
    local index=1
    pr(skynet.call("."..runconf.service.mysql.servicename..index ,"lua","select","table1",{id=1},{"id","name"}))
    index=index+1
    pr(skynet.call("."..runconf.service.mysql.servicename..index,"lua","select","table1",{id=1}))
    index=index+1
    pr(skynet.call("."..runconf.service.mysql.servicename..index,"lua","update","table1",{id=1},{name="koll1009"}))  index=index+1
    pr(skynet.call("."..runconf.service.mysql.servicename..index,"lua","insert","table1",{name="leidanling",age=33}))  index=index+1
    pr(skynet.call("."..runconf.service.mysql.servicename..index,"lua","delete","table1",{id=1}))
    --[[
 
        pr(db:insert("table1",{id=3,name="insert",age=33}))
        pr(db:insert("table1",{id=4,name="insert",age=33}))
        pr(db:insert("table1",{id=5,name="insert",age=33}))
        pr(db:insert("table1",{id=5,name="insert",age=33}))
        pr(db:delete("table1",{id=4,name="koll"}))
        pr(db:delete("table1",{id=4}))
        --]]
    skynet.exit()
end
)