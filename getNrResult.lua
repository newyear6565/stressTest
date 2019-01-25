-- example HTTP POST script which demonstrates setting the
-- HTTP method, body, and adding a header

wrk.method = "POST"
wrk.scheme = "http"
wrk.host = "47.92.203.173"
wrk.port = "9685"
wrk.path = "/v1/user/getNrList"
wrk.body   = "{\"hash\":\"}"
wrk.headers["Content-Type"] = "application/json"

require "nrid"

--function delay()
--    return 1
--end

function request()
    i = math.random(1, #nrids)
    body = "{\"hash\":\""..nrids[i].."\"}"
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
