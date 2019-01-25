-- example HTTP POST script which demonstrates setting the
-- HTTP method, body, and adding a header
require "height"

wrk.method = "POST"
wrk.scheme = "http"
wrk.host = "47.92.203.173"
wrk.port = "9685"
wrk.path = "/v1/user/getDipList"
wrk.body   = "{\"height\":0}"
wrk.headers["Content-Type"] = "Accept:application/json"

--function delay()
--    return 1
--end

begin = startHeight
endn = endHeight

function request()
    body = "{\"height\":"..tostring(math.random(begin, endn)).."}"
    print (body)
    return wrk.format(wrk.method, wrk.path, wrk.headers, body)    
end

function response(status, headers, body)
  --if status ~= 200 then
    print(body)
    print(" ")
  --end
end
