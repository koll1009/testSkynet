local cjson=require "cjson"
local cmd={}
cmd.__index=cmd 

function cmd.open(file)
    local f=io.open(file,"r")
    local s=f:read("*a")
    f:close()
    local t={}
    t.datas=cjson.decode(s)
    setmetatable(t,cmd)
    return t
end

--[[
local hfile={}
hfile.__index=hfile
function hfile.open(filename)
    local file=io.open(filename..".h","w")
    local t={}
    t.file=file
    setmetatable(t,hfile)
    return t
end

function hfile:writeline(line)
    local file=self.file
    file:write(line.."\n")
end

function hfile:writeooc(filename)
    local def="_"..string.upper(filename).."H"
    self:writeline("#ifndef "..def)
    self:writeline("#define "..def)
end

function hfile:writeclass(file)
    self:writeline()
end
--]]

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

--[[
do
    local _tostring = tostring
    tostring = function(v)
        if type(v) == 'table' then
            return dump(v)
        else
            return _tostring(v)
        end
    end
end
--]]

local function create_h_file(filename)
    local h=io.open(filename..".h","w")
   
    h:write("#ifndef _"..string.upper(filename).."_H\n")
    h:write("#define _"..string.upper(filename).."_H\n")
    h:write("class "..filename.."\n")
    h:write("{\n")
    h:write("private:\n")
    h:write(filename.."();\n")
    h:write("~"..filename.."();\n")

    h:write("}\n")
    h:write("#endif")
    h:flush()
    h:close()
end

local function encodetype(obj)
    local ft=type(obj)
    if ft=="string" then 
       return 0x01
    elseif ft=="table" then 
        local v=obj[1]
        return 0x80|encodetype(v)

    elseif ft=="number" then 
        if math.floor(obj)~=obj then 
            return 0x02
        else
            return 0x04
        end
    elseif ft=="boolean" then 
        return 0x08
    else
        print(".................error.....................")
    end

end
local function decodetype(t)
    local str,array
    if t&0x80==0x80 then 
        array=true
    end
    local t=t&0x0f
    if t==0x01 then 
        str="string"
    elseif t==0x02 then 
        str="double"
    elseif t==0x04 then 
        str="int"
    elseif t==0x08 then
        str="bool"
    end
    return str,array
end
local function create_data_file(name,fields,types)
    local filename=name.."Data"
    local h=io.open(filename..".h","w")

    h:write("#ifndef _"..string.upper(filename).."_H\n")
    h:write("#define _"..string.upper(filename).."_H\n")
    h:write("#include <vector>\n using namespace std;\n")

    h:write("class "..filename.."\n")
    h:write("{\n")
    h:write("private:\n")
    h:write(filename.."(")
    local ff={}
    local params={}
    local init={}
    local init_params={}
    local r_params={}
    local init_body={}
    local len=#fields
 
    for i=1,len do 
        local t=nil
        local a=nil
        t,a=decodetype(types[i])
        local field=fields[i]
        table.insert(init,field.."("..field..")")
        if a then 
     
            table.insert(ff,"vector<"..t..">& "..field)
            --table.insert(params,t.." "..field.."[]")
            table.insert(params,"vector<"..t..">& "..field)
            --[[
            table.insert(init_params,t.." "..field.."[]")     
            table.insert(r_params,field)

            local statement="len=sizeof("..field..")/sizeof("..t..");\n"
            statement=statement.."for(int i=0;i<len;i++)\n{"
            statement=statement.."\t".."this->"..field..".push_back("..field.."[i]);\n}"
            table.insert(init_body,statement)
            --]]
        else
           
            table.insert(ff,t.." "..field)
            table.insert(params,t.." "..field)
        end
    end
    local init_len=#init_params 

    h:write(table.concat(params,","))
    h:write("):\n")

    h:write(table.concat(init,","))
    h:write("{\n")
    --[[] 
    if init_len>0 then 
        h:write("\tthis->init(")
        h:write(table.concat(r_params,","))
        h:write(");\n")
    end
    --]]
    h:write("}\n")
    h:write("~"..filename.."(){}\n")  

    --[[ 
    if init_len>0 then
        h:write("private:\n")
        h:write("void init(")
        h:write(table.concat(init_params,","))
        h:write(")\n{\n")
        h:write("int len;\n")
        h:write(table.concat(init_body,"\n"))
        h:write("}\n")
    end
    --]]

    h:write("public:\n")
    h:write(table.concat(ff,";\n"))
    h:write(";\n")

    h:write("};\n")
    h:write("#endif")
    h:flush()
    h:close()
end
local function create_cpp_file(filename,tool,version,data)
    local cpp=io.open(filename..".cpp","w")
    cpp:write("#include \""..filename..'.h"\n')
    cpp:write("//Tool:"..tool.."\n")
    cpp:write("//Version:"..version.."\n")
    local ss={}
    local fields={}
    local ftypes={}
    for _,v in ipairs(data) do 
        local s=nil
        for key,value in pairs(v) do
            table.insert(fields,key)
            table.insert(ftypes,encodetype(value))
            s=s and s..","..key..":"..tostring(value) or key..":"..tostring(value)
        end
        table.insert(ss,v)
    end
    create_data_file(filename,fields,ftypes)
    cpp:flush()
    cpp:close()

end

function cmd:parse()
    local t=self.datas
    local tool,version,data,filename
    for k,v in pairs(t) do 
        if k=="Tool" then 
            tool=v
        elseif k=="Version" then 
            version=v
        else
            filename=k
            data=v
        end
    end
    create_h_file(filename)
    create_cpp_file(filename,tool,version,data)
end

return cmd