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
                {keepalive = { default = 60000, type = "number" }}
            }
        }
    }
  }
}
