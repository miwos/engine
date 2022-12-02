local class = require('class')

---@class Patch
---@field modules table<string, Module>
local Patch = class()

function Patch:constructor()
  self.modules = {}
  self.connections = {}
end

---@param moduleType string
---@param moduleId number
function Patch:addModule(moduleType, moduleId)
  local Module = Miwos.moduleDefinitions[moduleType]
  if not Module then
    error(string.format('module type `%s` not found', moduleType))
  end

  if self.modules[moduleId] then
    Log.warn(string.format('module with id `%s` already exists', moduleId))
    return
  end

  local module = Module()
  module.__id = moduleId
  module.__name = moduleType .. '@' .. moduleId
  self.modules[moduleId] = module

  return true
end

---@param moduleId number
function Patch:removeModule(moduleId)
  self.modules[moduleId] = nil
end

return Patch
