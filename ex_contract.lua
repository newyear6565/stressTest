-- example HTTP POST script which demonstrates setting the
-- HTTP method, body, and adding a header

require "nonce"
require "contract"
require "accounts"

wrk.method = "POST"
wrk.scheme = "http"
wrk.host = "localhost"
wrk.port = "9685"
wrk.path = "/v1/admin/transactionWithPassphrase"
wrk.body   = "{\"transaction\":{\"from\":\"%s\",\"to\":\"%s\", \"value\":\"100\",\"nonce\":%d,\"gasPrice\":\"1000000\",\"gasLimit\":\"2000000\",\"contract\":{\"function\":\"save\",\"args\":\"[0]\"}}, \"passphrase\": \"123456\"}"
wrk.headers["Content-Type"] = "Accept:application/json"

function request()
    i = math.random(1, #accounts)
    c = math.random(1, #contractArray)
    nonces[i] = nonces[i]+1
    body = string.format(wrk.body, accounts[i], contractArray[c], nonces[i])
    print(i)
    print(nonces[i])
    print(body)
    return wrk.format(wrk.method, wrk.path, wrk.headers, body)
end

function response(status, headers, body)
  --if status ~= 200 then
    print(status)
    print(body)
    print(" ")
  --end
end
