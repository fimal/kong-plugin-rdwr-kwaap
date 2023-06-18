local fixtures = {
    http_mock = {
        enforcer = [[
            server {
                listen 1234 backlog=1024;
                chunked_transfer_encoding on;
                location / {
                    return 200 "OK";
                }
            }
            ]],
        upstream = [[
            server {
                listen 5678 backlog=1024;
                chunked_transfer_encoding on;
                location / {
                    return 200 "OK\n";
                }
            }
            ]]
    }
}
return fixtures