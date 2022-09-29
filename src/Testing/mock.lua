local utils = require('utils')

local mockFunctionMeta = {
  __call = function(self, ...)
    self.calls = self.calls + 1
    self.args = { ... }
  end,
}

local function serialize(self)
  return 'fn()'
end

local function createMockFunction()
  return setmetatable({
    calls = 0,
    args = {},
    serialize = serialize,
  }, mockFunctionMeta)
end

return createMockFunction
