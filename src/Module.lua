local class = require('class')
local utils = require('utils')

---@class Module : Class
---@field __type string
---@field __definition table
---@field __events table<string, function>
---@field setup function | nil
---@field destroy function | nil
local Module = class()
Module.__hmrKeep = {}

function Module:constructor(props)
  self.__inputs = {}
  self.__outputs = {}
  self.__activeNotes = {}
  self.props = self:getPropsWithDefaults(props or {})

  utils.callIfExists(self.setup, self)
end

function Module:serializeDefinition()
  local props = {}
  for key, definition in pairs(self.__definition.props or {}) do
    local Component, options = unpack(definition)
    props[key] = { Component.__type, options }
  end

  return {
    id = self.__type,
    inputs = self.__definition.inputs,
    outputs = self.__definition.outputs,
    shape = self.__definition.shape,
    props = props,
  }
end

function Module:getPropsWithDefaults(props)
  for key, definition in pairs(self.__definition.props or {}) do
    if props[key] == nil then props[key] = definition[2].value end
  end
  return props
end

function Module:event(name, handler)
  self.__events[name] = handler
end

function Module:callEvent(name, ...)
  utils.callIfExists(self.__events[name], self, ...)
end

---@type fun(self, outputIndex: number, moduleId: number, inputIndex: number)
function Module:__connect(outputIndex, moduleId, inputIndex)
  self.__outputs[outputIndex] = self.__outputs[outputIndex] or {}
  table.insert(self.__outputs[outputIndex], { moduleId, inputIndex })
end

---@type fun(self, outputIndex: number, moduleId: number, inputIndex: number)
function Module:__disconnect(outputIndex, moduleId, inputIndex)
  for index, connection in pairs(self.__outputs[outputIndex] or {}) do
    if connection[0] == moduleId and connection[1] == inputIndex then
      connection[index] = nil
      return
    end
  end
end

---@type fun(self, index: number, message: MidiMessage|nil, cable: number )
function Module:output(index, message, cable)
  local signal = message and 'midi' or 'trigger'
  local isNoteOn = message and message:is(Midi.NoteOn)
  local isNoteOff = message and message:is(Midi.NoteOff)

  if isNoteOn or isNoteOff then
    ---@cast message MidiNoteOn | MidiNoteOff
    local noteId = Midi:getNoteId(message)
    self.__activeNotes[index] = self.__activeNotes[index] or {}
    self.__activeNotes[index][noteId] = isNoteOn and true or nil
  end

  self:__output(index, message)
end

function Module:__output(index, message)
  if self.__outputs[index] then
    for _, input in pairs(self.__outputs[index]) do
      local inputId, inputIndex = unpack(input)
      local inputModule = Miwos.patch and Miwos.patch.modules[inputId]
      if inputModule then
        local name = message and message.name or 'trigger'
        local numberedInput = 'input[' .. inputIndex .. ']'

        inputModule:callEvent('input', inputIndex, message)
        inputModule:callEvent('input:' .. name, inputIndex, message)
        inputModule:callEvent(numberedInput, message)
        inputModule:callEvent(numberedInput .. ':' .. name, message)
      end
    end
  end
end

---@param output? number
function Module:__finishNotes(output)
  for index, noteIds in pairs(self.__activeNotes) do
    if not output or index == output then
      for noteId in pairs(noteIds) do
        local note, channel = Midi.parseNoteId(noteId)
        self:__output(index, Midi.NoteOff(note, 0, channel))
      end
    end
  end
end

function Module:__saveState()
  local state = { props = self.props, __outputs = self.__outputs }

  for _, key in pairs(self.__hmrKeep) do
    state[key] = self[key]
  end

  return state
end

function Module:__applyState(state)
  -- Merge props instead of assigning them, incase a new prop was added that
  -- wasn't part of the last state.
  for key, value in pairs(state.props) do
    self.props[key] = value
  end

  self.__outputs = state.__outputs
  for _, key in pairs(self.__hmrKeep) do
    if state[key] ~= nil then self[key] = state[key] end
  end
end

function Module:__destroy()
  self:__finishNotes()
  utils.callIfExists(self.destroy, self)
end

function Module.__hmrAccept(definition)
  if Miwos.patch then Miwos.patch:updateModuleDefinition(definition) end
end

function Module.__hmrDecline(definition)
  -- We only want to hot replace actual modules, not the (abstract) module base
  -- class itself. Only modules registered with `Miwos.defineModule()` have a
  -- `__type`.
  return not definition.__type
end

return Module
