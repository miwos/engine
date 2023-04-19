local class = require('class')
local Utils = require('utils')

---@class Patch: Class
---@field modules table<number, Module>
---@field modulators table<number, Modulator>
---@field modulations table[]
---@field mappings table[]
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
  local definition = Miwos.moduleDefinitions[type]
  local module = definition and definition.module
  if not module then
    error(string.format('module type `%s` not found', type))
  end

  if self.modules[id] or self.modulators[id] then
    Log.warn(
      string.format('module or modulator with id `%s` already exists', id)
    )
    return false
  end

  local instance = module(props)
  instance.__id = id
  instance.__name = type .. '@' .. id
  self.modules[id] = instance

  return true
end

function Patch:getModule(moduleId)
  local module = self.modules[moduleId]
  if not module then
    Log.warn(string.format('module with id `%s` not found', moduleId))
  end
  return module
end

---@param id number
---@param type string
---@param props table
---@return boolean
function Patch:addModulator(id, type, props)
  local definition = Miwos.modulatorDefinitions[type]
  local modulator = definition and definition.modulator

  if not modulator then
    error(string.format('modulator type `%s` not found', type))
  end

  if self.modulators[id] or self.modules[id] then
    Log.warn(
      string.format('module or modulator with id `%s` already exists', id)
    )
    return false
  end

  local instance = modulator(props)
  instance.__id = id
  instance.__name = type .. '@' .. id
  self.modulators[id] = instance

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

---@param moduleId number
---@param name string
---@return table?
function Patch:getPropModulation(moduleId, name)
  for _, modulation in pairs(self.modulations) do
    if modulation[2] == moduleId and modulation[3] == name then
      return modulation
    end
  end
end

---@param moduleId number
---@param name string
---@param value any
function Patch:updatePropValue(moduleId, name, value)
  local module = self:getModule(moduleId)
  if not module then return end

  -- If the prop is modulated, the `Patch:updateModulations` method will take
  -- care of calling prop change events (with the modulated value) on the
  -- module, so we only have to set the prop value.
  local propIsModulated = self:getPropModulation(moduleId, name)
  if propIsModulated then
    module.__propValues[name] = value
    return
  end

  self:__updatePropValue(module, module.__propValues, name, value)
end

---@param moduleId number
---@param name string
---@param value any
function Patch:updateModulatedPropvalue(moduleId, name, value)
  local module = self:getModule(moduleId)
  if not module then return end

  self:__updatePropValue(module, module.__propValuesModulated, name, value)
end

---@param module Module
---@param props table<string, any>
---@param name string
---@param value any
function Patch:__updatePropValue(module, props, name, value)
  local valueHasChanged = props[name] ~= value
  if not valueHasChanged then return end

  module:callEvent('prop:beforeChange', name, value)
  module:callEvent('prop[' .. name .. ']:beforeChange', value)

  props[name] = value

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
      local baseValue = module.__propValues[prop]
      local modulationValue = modulator:value(time)
      local value =
        definition.modulateValue(baseValue, modulationValue, amount, options)
      self:updateModulatedPropvalue(moduleId, prop, value)
      -- TODO: notify bridge
      -- Bridge.notify('/e/modules/prop', moduleId, prop, value)
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
