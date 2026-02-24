local access = require "kong.plugins.middleman.access"

local MiddlemanHandler = {
    VERSION = "0.0.1",
    PRIORITY = 1051
}

MiddlemanHandler.access = access

return MiddlemanHandler
