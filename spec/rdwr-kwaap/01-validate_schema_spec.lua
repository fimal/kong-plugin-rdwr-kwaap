local helpers    = require "spec.helpers"
local PLUGIN_NAME = "rdwr-kwaap"
local schema_def = require("kong.plugins."..PLUGIN_NAME..".schema")
local v = helpers.validate_plugin_config_schema

describe("Plugin: " .. PLUGIN_NAME .. " (schema), ", function()
  it("minimal conf validates", function()
    assert(v({ }, schema_def))
  end)
  it("full conf validates", function()
    assert(v({
      enforcer_service_address= "127.0.0.1",
      enforcer_service_port= 80,
      max_req_bytes= 10240,
      fail_open= true,
      connect_timeout= 1000,
      send_timeout= 1000,
      read_timeout= 1000,
      keepalive= true
    }, schema_def))
  end)
  it("enforcer_service_port invalid value", function()
    local config = { enforcer_service_port = "mistake" }
    local ok, err = v(config, schema_def)
    assert.falsy(ok)
    -- print(err.config)
    assert.same({
      enforcer_service_port = 'expected a number'
    }, err.config)
  end)
end)