local class = require('class')
local Module = require('Module')
local Patch = require('Patch')

---@class Miwos
---@field patch Patch | nil
Miwos = _G.Miwos or {}

Miwos.modules = {}

function Miwos.loadPatch() end

function Miwos.createPatch()
  local patch = Patch()
  Miwos.patch = patch
  return Patch
end

---Create and register a new module.
---@param name string
---@return Module
function Miwos.createModule(name)
  local module = class(Module)
  module.__type = name
  module.__events = {}
  Miwos.modules[name] = Module
  return module
end
