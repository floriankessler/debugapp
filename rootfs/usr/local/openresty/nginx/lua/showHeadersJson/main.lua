cjson = require("cjson")

local h = ngx.req.get_headers()

ngx.header["Content-type"] = 'application/json'
ngx.say(cjson.encode(h))
