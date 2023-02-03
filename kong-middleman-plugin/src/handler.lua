local access = require "kong.plugins.middleman.access"

local MiddlemanHandler = {
    VERSION = "0.0.1",
    PRIORITY = 900
}

MiddlemanHandler.access = access

return MiddlemanHandler
