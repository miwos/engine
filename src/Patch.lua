local class = require('class')

---@class Patch
---@field moduleInstances table<string, Module>
local Patch = class()

function Patch:constructor()
  self.moduleInstances = {}
end

---@param moduleId string
---@param instanceId number
function Patch:addModuleInstance(moduleId, instanceId)
  local Module = Miwos.modules[moduleId]
  if not Module then
    error(string.format('module `%s` not found', moduleId))
  end

  if self.moduleInstances[instanceId] then
    Log.warn(string.format('Module@%s already exists', instanceId))
    return
  end

  local instance = Module()
  instance.__id = instanceId
  instance.__name = moduleId .. '@' .. instanceId
  self.moduleInstances[instanceId] = instance

  return true
end

return Patch
