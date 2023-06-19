local helpers    = require "spec.helpers"
local PLUGIN_NAME = "rdwr-kwaap"
local schema_def = require("kong.plugins."..PLUGIN_NAME..".schema")
local ENFORCER_SERVICE_PORT = 55555
local ENFORCER_SERVICE_ADDRESS = "localhost"

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
        hosts = { "fail-open.kwaf-demo.test" },
        paths = {"/api"},
        strip_path = true,
      }
      local route2 = bp.routes:insert {
        hosts = { "fail-close.kwaf-demo.test" },
        paths = {"/api"},
        strip_path = true,
      }

      local httpbin_service = bp.services:insert {
          name = "httpbin",
          protocol = "http",
          host= "fail.kwaf-demo.test",
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
        keepalive= true,
        inspection_fail_reason="CustomNotAcceptable"},
      }
      bp.plugins:insert {
        route = { id = route2.id },
        name     = PLUGIN_NAME,
        config   = {
        enforcer_service_address= ENFORCER_SERVICE_ADDRESS,
        enforcer_service_port= ENFORCER_SERVICE_PORT,
        max_req_bytes= 10240,
        fail_open= false,
        connect_timeout= 1000,
        send_timeout= 1000,
        read_timeout= 1000,
        keepalive= true,
        inspection_fail_reason="CustomNotAcceptable"},
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
    
    it("request get ; fail open ; 200 OK ; path: /api", function()
      local res = assert( proxy_client:send {
        method  = "GET",
        path    = "/api",
        headers =  { host = "fail-open.kwaf-demo.test" }
      })
      assert.response(res).has.status(200)
    end)

    it("request get ; fail close ; 406 CustomNotAcceptable ; path: /api", function()
      local res = assert( proxy_client:send {
        method  = "GET",
        path    = "/api",
        headers = {
          host           = "fail-close.kwaf-demo.test",
          ["user-agent"] = "Googlebot/2.1 (+http://www.google.com/bot.html)"
        },
      })
      assert.response(res).has.status(406)
      local body = string.gsub(res:read_body(), "^%s*(.-)%s*$", "%1")
      assert.same(body, "CustomNotAcceptable")
    end)
  end)
  end