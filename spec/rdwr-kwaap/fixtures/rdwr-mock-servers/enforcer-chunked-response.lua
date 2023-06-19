local fixtures = {
    http_mock = {
        enforcer = [[
            server {
                listen 1234 backlog=1024;
                chunked_transfer_encoding on;
                location / {
                        content_by_lua_block {
                            ngx.req.read_body()
                            ngx.status = 200
                            ngx.exit(200)
                        }
                }
            }
            ]],
        upstream = [[
            server {
                listen 5678 backlog=1024;
                chunked_transfer_encoding on;
                location / {
                    content_by_lua_block {
                        ngx.req.read_body()
                        ngx.say(ngx.req.get_headers()["Content-Length"])
                        ngx.print(ngx.req.get_body_data())
                    }
                }
            }
            ]]
    }
}
return fixtures