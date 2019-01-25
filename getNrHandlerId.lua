-- example HTTP POST script which demonstrates setting the
-- HTTP method, body, and adding a header
require "height"


wrk.method = "POST"
wrk.scheme = "http"
wrk.host = "47.92.203.173"
wrk.port = "9685"
wrk.path = "/v1/user/getNrHash"
wrk.body   = "{\"start\":\"}"
wrk.headers["Content-Type"] = "application/json"


start = startHeight
endh = endHeight

--function delay()
--    return 1
--end

function request()
    body = "{\"start\":"..tostring(start)..",\"end\":"..tostring(start + 200).."}"
    start = start + 200
    if(start + 200 > endh) then
        start = 1600
    end
    --print("{\"start\":", start, ", \"body\":", body, "}")
    print(body)
    return wrk.format(wrk.method, wrk.path, wrk.headers, body)
end

function response(status, headers, body)
  --if status ~= 200 then
  --print(status)
    print(body)
    print(" ")
  --end
end
