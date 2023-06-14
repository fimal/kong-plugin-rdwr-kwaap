# HOW TO RUN
```bash
# specific test
KONG_VERSION="3.3.0"  pongo run --no-cassandra -- --exclude-tags=cassandra spec/rdwr-kwaap/02-handler-get_spec.lua 
# no cassandra
KONG_VERSION="3.3.0"  pongo run --no-cassandra -- --exclude-tags=cassandra
# quick run
KONG_VERSION="3.3.0"  pongo run --exclude-tags=cassandra -o TAP
# detailed run
KONG_VERSION="3.3.0"  pongo run --exclude-tags=cassandra -o gtest
```
## mock server
    spec/fixtures/custom_nginx.template
## strategy
 DB strategy, this will iterate on the default {“postgres", “cassandra"}
## busted 
busted syntax: https://olivinelabs.com/busted/#overview
## define classic busted functions:
    lazy_setup - to set up all the components,
    lazy_teardown - to shutdown all the components,
    before_each andafter_each - that will be execute before and after each test.

# Asserts
    Asserts are the core of busted; they're what you use to actually write your tests. Asserts in busted work by chaining a modifier value by using is or is_not, followed by the assert you wish to use. It's easy to extend busted and add your own asserts by building an assert with a commmon signature and registering it.

    Busted uses the luassert library to provide the assertions. Note that some of the assertion/modifiers are Lua keywords ( true, false, nil, function, and not) and they cannot be used using '.' chaining because that results in compilation errors. Instead chain using '_' (underscore) or use one or more capitals in the reserved word, whatever your coding style prefers.


### assert.falsy(ok) - check that the validation catches the error.
### assert.same - check the error description

## Entity checker
    at_least_one_of - The name is quite explicit, check if at least one of the field is set 
    conditional_at_least_one_of
    only_one_of
    distinct - When the value cannot be the same
    conditional - If one field matchs a test then another test should match a test
    custom_entity_check
    mutually_required - When several fields need each other
    mutually_exclusive_sets -Two set should be profited 
## Fields validator
    Generic:
    eq, ne, not_one_of, one_of

    type-dependent:
    gt, timestamp, uuid, is_regex, between,

    Strings:
    len_eq, len_min, len_max, starts_with, not_match, match_none, match, match_all, match_any

    Arrays:
    contains,

    Other:
    custom_validator, mutually_exclusive_subsets
## Is & Is Not
```lua
describe("some assertions", function()
  it("tests positive assertions", function()
    assert.is_true(true)  -- Lua keyword chained with _
    assert.True(true)     -- Lua keyword using a capital
    assert.are.equal(1, 1)
    assert.has.errors(function() error("this should fail") end)
  end)

  it("tests negative assertions", function()
    assert.is_not_true(false)
    assert.are_not.equals(1, "1")
    assert.has_no.errors(function() end)
  end)
end)
```
## Equals

```lua
describe("some asserts", function()
  it("checks if they're equals", function()
    local expected = 1
    local obj = expected

    assert.are.equals(expected, obj)
  end)
end)
```
## SAme
```lua
describe("some asserts", function()
  it("checks if they're the same", function()
    local expected = { name = "Jack" }
    local obj = { name = "Jack" }

    assert.are.same(expected, obj)
  end)
end)
```
## True & Truthy; False & Falsy
```lua
describe("some asserts", function()
  it("checks true", function()
    assert.is_true(true)
    assert.is.not_true("Yes")
    assert.is.truthy("Yes")
  end)

  it("checks false", function()
    assert.is_false(false)
    assert.is.not_false(nil)
    assert.is.falsy(nil)
  end)
end)
```
## Error
```lua
describe("some asserts", function()
  it("should throw an error", function()
    assert.has_error(function() error("Yup,  it errored") end)
    assert.has_no.errors(function() end)
  end)

  it("should throw the error we expect", function()
    local errfn = function()
      error("DB CONN ERROR")
    end

    assert.has_error(errfn, "DB CONN ERROR")
  end)
end)
```
## Extending Your Own Assertions
```lua
local say = require("say")

local function has_property(state, arguments)
  local has_key = false

  if not type(arguments[1]) == "table" or #arguments ~= 2 then
    return false
  end

  for key, value in pairs(arguments[1]) do
    if key == arguments[2] then
      has_key = true
    end
  end

  return has_key
end

say:set("assertion.has_property.positive", "Expected %s \nto have property: %s")
say:set("assertion.has_property.negative", "Expected %s \nto not have property: %s")
assert:register("assertion", "has_property", has_property, "assertion.has_property.positive", "assertion.has_property.negative")

describe("my table", function()
  it("has a name property", function()
    assert.has_property({ name = "Jack" }, "name")
  end)
end)
```
