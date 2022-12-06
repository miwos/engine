local class = require('class')
local EventEmitter = require('EventEmitter')
local utils = require('utils')

---@class Module : Class, EventEmitter
---@field init function | nil
local Module = class(EventEmitter)

function Module:constructor()
  self.__inputs = {}
  self.__outputs = {}
  self.__activeNotes = {}

  utils.callIfExists(self.init, self)
end

function Module:defineProps(definitions)
  for index, prop in ipairs(definitions) do
    prop.index = index
  end
  self.__propDefinitions = definitions
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

  self:__output(signal, index)
end

function Module:__output(index, message)
  if self.__outputs[index] then
    for _, input in pairs(self.__outputs[index]) do
      local inputId, inputIndex = unpack(input)
      local inputModule = Miwos.patch and Miwos.patch.modules[inputId]
      if inputModule then
        local name = message and message.name or 'trigger'
        local numberedInput = 'input[' .. inputIndex .. ']'

        -- Emit various input events (e.g.: 'input', 'input:noteOn', 'input[1]',
        -- input[1]:noteOn).
        inputModule:emit('input', inputIndex, message)
        inputModule:emit('input:' .. name, inputIndex, message)
        inputModule:emit(numberedInput, message)
        inputModule:emit(numberedInput .. ':' .. name, message)
      end
    end
  end
end

return Module
