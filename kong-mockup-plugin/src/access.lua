local kong_response = kong.response
local http = require"socket.http"
local ltn12 = require"ltn12"
local JSON = require "kong.plugins.mockup.json"
local cjson = require("cjson")


return function (self, conf)
  ngx.log(ngx.NOTICE,"start")
    local keycloak_url = conf.url .. "/auth/realms/master/protocol/openid-connect/token"
    local user_id = conf.userid
    local user_name = conf.username 
    local password = conf.password 
    local client_id = conf.clientid 

    local payload = "grant_type=password&username=" .. user_name .. "&password=" .. password .. "&client_id=" .. client_id
    
    local response_body = { }
    
    local res, code, response_headers, status = http.request
    {
      url = keycloak_url,
      method = "POST",
      headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = payload:len()
      },
      source = ltn12.source.string(payload),
      sink = ltn12.sink.table(response_body)
    }

    ngx.log(ngx.NOTICE,status)
    
    if code > 299 then
      return kong_response.send(code,table.concat(response_body))
    end 

    local response_decoded = cjson.decode(table.concat(response_body))
    local token = response_decoded["access_token"]
    ngx.req.set_header("Authorization", "Bearer " .. token)
    ngx.req.set_header("X-UserID", user_id)
end
