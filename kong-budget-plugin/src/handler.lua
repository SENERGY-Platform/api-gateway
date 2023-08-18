local access = require "kong.plugins.budget.access"

local BudgetHandler = {
    VERSION = "0.0.1",
    PRIORITY = 100
}

BudgetHandler.access = access

return BudgetHandler
