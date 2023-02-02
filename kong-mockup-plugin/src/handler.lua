local access = require "kong.plugins.mockup.access"

local MockupHandler = {
    VERSION = "0.0.1",
    PRIORITY = 900
}

MockupHandler.access = access

return MockupHandler
