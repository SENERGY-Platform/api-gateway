return {
  name = "mockup",
  entity_checks = {},
  fields = {
    {
        config = {
            type = "record",
            fields = {
                {url = {required = true, type = "string"}},
                {username = {required = true, type = "string"}},
                {password = {required = true, type = "string"}},
                {userid = {required = true, type = "string"}},
                {clientid = {required = true, type = "string"}}
            }
        }
    }
  }
}
