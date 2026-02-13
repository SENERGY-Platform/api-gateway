return {
  name = "middleman",
  entity_checks = {},
  fields = {
    {
        config = {
            type = "record",
            fields = {
                {url = {required = true, type = "string"}},
                {response = { required = true, default = "table", type = "string", one_of = {"table", "string"}}},
                {timeout = { default = 10000, type = "number" }},
                {keepalive = { default = 60000, type = "number" }},
                {blacklist_uri_pattern = { description = "Matches incoming requests (full path '/route/path/sub-path', but without query params) against this list of patterns. If any pattern matches, the request is blocked with HTTP Code 403. Check the reference for valid patterns: https://www.luadocs.com/docs/functions/string/match#pattern-table", default = {}, type = "array", elements = { type =  "string" }}}
            }
        }
    }
  }
}
