local class = require('class')

---@class Patch: Class
---@field modules table<number, Module>
local Patch = class()

function Patch:constructor()
  self.modules = {}
  self.connections = {}
  self.mappings = {}
end

---@type fun(self, id: number, type: string, props?: table): boolean
function Patch:addModule(id, type, props)
  local Module = Miwos.moduleDefinitions[type]
  if not Module then
    error(string.format('module type `%s` not found', type))
  end

  if self.modules[id] then
    Log.warn(string.format('module with id `%s` already exists', id))
    return false
  end

  local module = Module(props)
  module.__id = id
  module.__name = type .. '@' .. id
  self.modules[id] = module

  return true
end

---@type fun(self, moduleId: number)
function Patch:removeModule(moduleId)
  local module = self.modules[moduleId]
  module:__destroy()
  self.modules[moduleId] = nil
end

function Patch:clear()
  for id in pairs(self.modules) do
    self:removeModule(id)
  end
  self.connections = {}
  self.mappings = {}
  -- TODO: clear PropsView
end

function Patch:updateProp(moduleId, name, value)
  local module = self.modules[moduleId]
  if not module then
    Log.warn(string.format('module with id `%s` not found', moduleId))
    return false
  end

  module:callEvent('prop:beforeChange', name, value)
  module:callEvent('prop[' .. name .. ']:beforeChange', value)

  module.props[name] = value

  module:callEvent('prop:change', name, value)
  module:callEvent('prop[' .. name .. ']:change', value)
end

function Patch:deserialize(serialized)
  self.modules = {}
  for _, serializedModule in pairs(serialized.modules) do
    self:addModule(
      serializedModule.id,
      serializedModule.type,
      serializedModule.props
    )
  end

  self.connections = {}
  for _, connection in pairs(serialized.connections) do
    local fromId, fromIndex, toId, toIndex = unpack(connection)
    self.modules[fromId]:__connect(fromIndex, toId, toIndex)
  end

  self.mappings = serialized.mappings or {}
  for _, page in pairs(self.mappings) do
    for slot, mapping in pairs(page) do
      -- Resolve the module and store it instead of the module id.
      local id, name = unpack(mapping)
      local module = self.modules[id]
      page[slot] = { module, name }
    end
  end
end

return Patch
