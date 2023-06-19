local helpers    = require "spec.helpers"
local PLUGIN_NAME = "rdwr-kwaap"
local schema_def = require("kong.plugins."..PLUGIN_NAME..".schema")
local ENFORCER_SERVICE_PORT = 15555
local ENFORCER_SERVICE_ADDRESS = "localhost"
-- local ENFORCER_SERVICE_PORT = 31012
-- local ENFORCER_SERVICE_ADDRESS = "10.195.5.195"

for _, strategy in helpers.each_strategy() do
  describe("Plugin: " .. PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local proxy_client

    lazy_setup(function()
      local bp = helpers.get_db_utils(strategy, {
        "plugins",
        "routes",
        "services",
      })

      local route1 = bp.routes:insert {
        hosts = { "httpbin.kwaf-demo.test" },
        paths = {"/api"},
        strip_path = true,
      }

      local httpbin_service = bp.services:insert {
          name = "httpbin",
          protocol = "http",
          host= "httpbin.kwaf-demo.test",
      }
      bp.plugins:insert {
        route = { id = route1.id },
        name     = PLUGIN_NAME,
        config   = {
        enforcer_service_address= ENFORCER_SERVICE_ADDRESS,
        enforcer_service_port= ENFORCER_SERVICE_PORT,
        max_req_bytes= 10240,
        fail_open= true,
        connect_timeout= 1000,
        send_timeout= 1000,
        read_timeout= 1000,
        keepalive= true},
      }
      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong()
    end)

    before_each(function()
      proxy_client = helpers.proxy_client()
    end)

    after_each(function()
      if proxy_client then
        proxy_client:close()
      end
    end)

    it("request get ; 200 OK ; path: /api", function()
      local res = assert( proxy_client:send {
        method  = "GET",
        path    = "/api/get",
        headers =  { host = "httpbin.kwaf-demo.test" }
      })
      assert.response(res).has.status(200)
    end)

    it("request get ; 404 NOT FOUND ; path: /api/1.log", function()
      local res = assert( proxy_client:send {
        method  = "GET",
        path    = "/api/get/1.log",
        headers = {
          host           = "httpbin.kwaf-demo.test",
          ["user-agent"] = "Googlebot/2.1 (+http://www.google.com/bot.html)"
        },
      })
      assert.response(res).has.status(200)
    end)
  end)
  end