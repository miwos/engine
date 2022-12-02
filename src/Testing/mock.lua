local mockFunctionMeta = {
  __call = function(self, ...)
    self.calls = self.calls + 1
    self.args = { ... }
  end,
}

local function serialize()
  return 'fn()'
end

local function createMockFunction()
  local mock = setmetatable({
    calls = 0,
    args = {},
    serialize = serialize,
  }, mockFunctionMeta)

  ---@cast mock -table, +function
  return mock
end

return createMockFunction
