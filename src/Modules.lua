local class = require('class')
local Module = require('Module')
Modules = _G.Modules or {}

---Return a new module class.
---@param name string
---@return table
function Modules.create(name, info)
  local module = class(Module)
  module.__type = name
  module.__events = {}
  module.__info = info
  return module
end
