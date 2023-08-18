package = "budget"

version = "0.1.1-1"

-- The version '0.1.1' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

supported_platforms = {"linux", "macosx"}

source = {
  url = "",
  tag = "0.1.1"
}

description = {
  summary = ""
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.budget.access"] = "src/access.lua",
    ["kong.plugins.budget.handler"] = "src/handler.lua",
    ["kong.plugins.budget.schema"] = "src/schema.lua",
	["kong.plugins.budget.json"] = "src/json.lua"
  }
}
