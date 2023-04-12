local class = require('class')

---@class Patch: Class
---@field modules table<number, Module>
---@field modulators table<number, Modulator>
local Patch = class()

function Patch:constructor()
  self.modules = {}
  self.modulators = {}
  self.connections = {}
  self.modulations = {}
  self.mappings = {}
end

---@param id number
---@param type string
---@param props table
---@return boolean
function Patch:addModule(id, type, props)
  local Module = Miwos.moduleDefinitions[type]
  if not Module then
    error(string.format('module type `%s` not found', type))
  end

  if self.modules[id] or self.modulators[id] then
    Log.warn(
      string.format('module or modulator with id `%s` already exists', id)
    )
    return false
  end

  local module = Module(props)
  module.__id = id
  module.__name = type .. '@' .. id
  self.modules[id] = module

  return true
end

---@param id number
---@param type string
---@param props table
---@return boolean
function Patch:addModulator(id, type, props)
  local Modulator = Miwos.modulatorDefinitions[type]
  if not Modulator then
    error(string.format('modulator type `%s` not found', type))
  end

  if self.modulators[id] or self.modules[id] then
    Log.warn(
      string.format('module or modulator with id `%s` already exists', id)
    )
    return false
  end

  local modulator = Modulator(props)
  modulator.__id = id
  modulator.__name = type .. '@' .. id
  self.modulators[id] = modulator

  return true
end

---@param moduleId number
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

---@param time number
function Patch:updateModulations(time)
  for _, modulation in pairs(self.modulations) do
    local modulatorId, moduleId, prop, amount = unpack(modulation)
    local modulator = self.modulators[modulatorId]
    local module = self.modules[moduleId]

    local component, options = unpack(module.__definition.props[prop])
    local definition = Miwos.propDefinitions[component.__type]

    if modulator then
      local oldValue = module.props[prop]
      local modulationValue = modulator:value(time)
      local value =
        definition.modulateValue(oldValue, modulationValue, 1, options)
      self:updateProp(moduleId, prop, value)
      Miwos:emit('prop:change', moduleId, prop, value)
      Bridge.notify('/e/modules/prop', moduleId, prop, value)
    else
      Log.warn(string.format('modulator with id `%s` not found', moduleId))
    end
  end
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

  self.connections = serialized.connections
  for _, connection in pairs(serialized.connections) do
    local fromId, fromIndex, toId, toIndex = unpack(connection)
    self.modules[fromId]:__connect(fromIndex, toId, toIndex)
  end

  self.modulators = {}
  for _, serializedModulator in pairs(serialized.modulators) do
    self:addModulator(
      serializedModulator.id,
      serializedModulator.type,
      serializedModulator.props
    )
  end

  self.modulations = serialized.modulations

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
