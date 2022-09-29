local assertions = require('Testing.assertions')
local fail = require('Testing.fail')
local Expect = {}

for name, value in pairs(assertions) do
  local fn, text = unpack(value)
  local textIsFunction = type(text) == 'function'

  Expect[name] = function(self, ...)
    local received = self.value
    if not fn(received, ...) then
      local failText = textIsFunction and text(false, received, ...) or text
      fail(name, failText, received, ...)
    end
  end

  local upper = name:gsub('^%l', string.upper)
  Expect['not' .. upper] = function(self, ...)
    local received = self.value
    if fn(received, ...) then
      local failText = textIsFunction and text(true, received, ...) or text
      fail('{underline not}' .. upper, failText, received, ...)
    end
  end
end

local function expect(value)
  return setmetatable({ value = value }, { __index = Expect })
end

return expect
