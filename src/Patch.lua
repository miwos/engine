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

---@param Definition Module
function Patch:updateModuleDefinition(Definition)
  for id, module in pairs(self.modules) do
    if module.__type == Definition.__type then
      local state = module:__saveState()
      module:__destroy()

      ---@type Module
      local newModule = Definition()
      newModule:__applyState(state)
      newModule.__id = id
      self.modules[id] = newModule

      for _, connection in ipairs(self.connections) do
        local _, fromIndex, toId, toIndex = unpack(connection)
        newModule:__connect(fromIndex, toId, toIndex)
      end
    end
  end
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

function Patch:addMapping(page, slot, id, prop)
  self.mappings[page] = self.mappings[page] or {}
  local module = self.modules[id]
  self.mappings[page][slot] = { module, prop }
end

function Patch:removeMapping(page, slot)
  if not self.mappings[page] then return end
  self.mappings[page][slot] = nil
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

  -- TODO: what is `connections = {}` doing?
  self.connections = serialized.connections
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
