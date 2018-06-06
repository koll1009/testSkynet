local skynet = require "skynet"
local logger = {}

local loglevel = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    default=5
}
local log_color_tag={
    {
        --debug 
        color="\x1b[32m",
        str="[debug] "
    },
    {
        --info
        color="\x1b[34m",
        str="[info] "
    },
    {
        --warn
        color="\x1b[33m",
        str="[warning] "
    },
    {
        --error
        color="\x1b[31m",
        str="[error] "
    },
    {
        --default
        color="\x1b[0m",
        str=""
    }
}
local logtag={
    string.format("%s%s", log_color_tag[loglevel.debug].color, log_color_tag[loglevel.debug].str),
    string.format("%s%s", log_color_tag[loglevel.info].color, log_color_tag[loglevel.info].str),
    string.format("%s%s", log_color_tag[loglevel.warn].color, log_color_tag[loglevel.warn].str),
    string.format("%s%s", log_color_tag[loglevel.error].color, log_color_tag[loglevel.error].str),
    string.format("%s%s", log_color_tag[loglevel.default].color, log_color_tag[loglevel.default].str),
}



local function init_log()
    if not logger._level then
        local level = skynet.getenv("log_level")
        local default_level = loglevel.debug
        local val

        if not level or not loglevel[level] then
            val = default_level
        else
            val = loglevel[level]
        end

        logger._level = val
    end
    --logger._name=skynet.self()
end

local function logmsg(level, format, ...)
    local n = logger._name and string.format("%s: ", logger._name) or ""
    skynet.error(logtag[level]..n..string.format(format, ...)..logtag[loglevel.default])
end

function logger.set_log_level(level)
    local val = loglevel.debug

    if level and loglevel[level] then
        val = loglevel[level]
    end

    logger._level = val
end
 


function logger.debug(format, ...)
    if logger._level <= loglevel.debug then
        logmsg(loglevel.debug, format, ...)
    end
end

function logger.info(format, ...)
    if logger._level <= loglevel.info then
        logmsg(loglevel.info, format, ...)
    end
end

function logger.warn(format, ...)
    if logger._level <= loglevel.warn then
        logmsg(loglevel.warn, format, ...)
    end
end

function logger.error(format, ...)
    if logger._level <= loglevel.error then
        logmsg(loglevel.error, format, ...)
    end
end



function logger.set_name(name)
    logger._name = name
end

init_log()


return logger


