local JSON = require "kong.plugins.middleman.json"
local cjson = require "cjson"
local url = require "socket.url"

local string_format = string.format

local kong_response = kong.response

local get_headers = ngx.req.get_headers
local get_uri_args = ngx.req.get_uri_args
local read_body = ngx.req.read_body
local get_body = ngx.req.get_body_data
local get_method = ngx.req.get_method
local ngx_re_match = ngx.re.match
local ngx_re_find = ngx.re.find

local HTTP = "http"
local HTTPS = "https"

return function (self, conf)
  if not conf.run_on_preflight and get_method() == "OPTIONS" then
    return
  end

  local name = "[middleman] "
  local ok, err
  local parsed_url = url.parse(conf.url)
  if not parsed_url.port then
    if parsed_url.scheme == HTTP then
      parsed_url.port = 80
     elseif parsed_url.scheme == HTTPS then
      parsed_url.port = 443
     end
  end
  if not parsed_url.path then
    parsed_url.path = "/"
  end
  local host = parsed_url.host
  local port = tonumber(parsed_url.port)

  local headers = get_headers()
  local uri_args = get_uri_args()
  local next = next

  read_body()
  local body_data = get_body()

  headers["target_uri"] = ngx.var.request_uri
  headers["target_method"] = ngx.var.request_method

  local url
  if parsed_url.query then
    url = parsed_url.path .. "?" .. parsed_url.query
  else
    url = parsed_url.path
  end

  local raw_json_headers = JSON:encode(headers)
  local raw_json_body_data = JSON:encode(body_data)

  local raw_json_uri_args
  if next(uri_args) then
    raw_json_uri_args = JSON:encode(uri_args)
  else
    -- Empty Lua table gets encoded into an empty array whereas a non-empty one is encoded to JSON object.
    -- Set an empty object for the consistency.
    raw_json_uri_args = "{}"
  end

  local payload_body = [[{"headers":]] .. raw_json_headers .. [[,"uri_args":]] .. raw_json_uri_args.. [[,"body_data":]] .. raw_json_body_data .. [[}]]

  local payload_headers = string_format(
    "POST %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n",
    url, parsed_url.host, #payload_body)

  local payload = string_format("%s\r\n%s", payload_headers, payload_body)

  local sock = ngx.socket.tcp()
  sock:settimeout(conf.timeout)

  ok, err = sock:connect(host, port)
  if not ok then
    ngx.log(ngx.ERR, name .. "failed to connect to " .. host .. ":" .. tostring(port) .. ": ", err)
    return kong_response.exit(502, "Bad Gateway: Could not connect to auth-service")
  end

  if parsed_url.scheme == HTTPS then
    local _, err = sock:sslhandshake(true, host, false)
    if err then
      ngx.log(ngx.ERR, name .. "failed to do SSL handshake with " .. host .. ":" .. tostring(port) .. ": ", err)
	  return kong_response.exit(502, "Bad Gateway: Could establish HTTPS connection with auth-service")
    end
  end

  ok, err = sock:send(payload)
  if not ok then
    ngx.log(ngx.ERR, name .. "failed to send data to " .. host .. ":" .. tostring(port) .. ": ", err)
	return kong_response.exit(502, "Bad Gateway: Could send request to auth-service")
  end

  local line, err = sock:receive("*l")

  if err then 
    ngx.log(ngx.ERR, name .. "failed to read response status from " .. host .. ":" .. tostring(port) .. ": ", err)
    return kong_response.exit(502, "Bad Gateway: Could not read status code from auth-service")
  end

  local status_code = tonumber(string.match(line, "%s(%d%d%d)%s"))
  local headers = {}

  repeat
    line, err = sock:receive("*l")
    if err then
      ngx.log(ngx.ERR, name .. "failed to read header " .. host .. ":" .. tostring(port) .. ": ", err)
      return kong_response.exit(502, "Bad Gateway: Could not read header from auth-service")
    end

    local pair = ngx_re_match(line, "(.*):\\s*(.*)", "jo")

    if pair then
      headers[string.lower(pair[1])] = pair[2]
    end
  until ngx_re_find(line, "^\\s*$", "jo")

  local body, err = sock:receive(tonumber(headers['content-length']))
  if err then
    ngx.log(ngx.ERR, name .. "failed to read body " .. host .. ":" .. tostring(port) .. ": ", err)
    return kong_response.exit(502, "Bad Gateway: Could not read body from auth-service")
  end

  ok, err = sock:setkeepalive(conf.keepalive)
  if not ok then
    ngx.log(ngx.ERR, name .. "failed to keepalive to " .. host .. ":" .. tostring(port) .. ": ", err)
    return kong_response.exit(502, "Bad Gateway: Could not set connection keepalive with auth-service")
  end

  if err then 
    ngx.log(ngx.ERR, name .. "failed to read response from " .. host .. ":" .. tostring(port) .. ": ", err)
	return kong_response.exit(502, "Bad Gateway: Could not read response from auth-service")
  end

  local response_body
  if conf.response == "table" then 
    response_body = JSON:decode(string.match(body, "%b{}"))
  else
    response_body = string.match(body, "%b{}")
  end

  if status_code > 299 then
    return kong_response.exit(status_code, response_body)
  else
    kong.service.request.set_header("X-UserID", response_body["userID"])
    kong.service.request.set_header("X-User-Roles", table.concat(response_body["roles"], ", "))
    local consumer, err = kong.db.consumers:select_by_custom_id(response_body["userID"])
    if err then
        kong_response.exit(500, err)
    end
    if not consumer then
        if not err then
            consumer = kong.db.consumers:insert {
                custom_id = response_body["userID"],
                tags = {"keycloak", "middleman"}
            }
        end
    end
    kong.client.authenticate(consumer, nil)
  end
end
