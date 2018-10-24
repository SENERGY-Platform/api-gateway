local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.mockup.access"

local MockupHandler = BasePlugin:extend()

MockupHandler.PRIORITY = 900

function MockupHandler:new()
  MockupHandler.super.new(self, "mockup")
end

function MockupHandler:access(conf)
  MockupHandler.super.access(self)
  access.execute(conf)
end

return MockupHandler