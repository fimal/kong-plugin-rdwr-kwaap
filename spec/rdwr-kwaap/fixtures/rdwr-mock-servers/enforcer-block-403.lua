local fixtures = {
    http_mock = {
        enforcer = [[
            server {
                listen 1234 backlog=1024;
                chunked_transfer_encoding off;
                location / {
                        content_by_lua_block {
                            -- ngx.req.read_body()
                            ngx.status = 403
                            ngx.say(ngx.req.get_headers()["Content-Length"])
                            ngx.say(ngx.req.get_headers()["x-enforcer-original-content-length"])
                            ngx.say(ngx.req.get_headers()["x-enforcer-auth-partial-body"])
                            ngx.exit(200)
                        }
                }
            }
            ]],
        upstream = [[
            server {
                listen 5678 backlog=1024;
                location / {
                    return 200 "OK\n";
                }
                }
            ]]
    }
}
return fixtures