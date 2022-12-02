---@class Class
---@field Class table
---@field super table

--A very basic class helper with inheritance.

---@type fun(base?: table): Class
local function class(base)
  local c = {}
  c.__index = c
  c.Class = c

  ---@type fun(_: table, ...: unknown): Class
  local function call(_, ...)
    local instance = setmetatable({}, c)
    if c.constructor then c.constructor(instance, ...) end
    return instance
  end

  if base then
    c.super = base
    local mt = setmetatable({ __index = base }, base)
    mt.__call = call
    setmetatable(c, mt)
  else
    setmetatable(c, { __call = call })
  end

  return c
end

return class
