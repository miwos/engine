local class = require('class')
local EventEmitter = require('EventEmitter')
local MidiMessage = require('MidiMessage')
local mixin = require('mixin')

---@class Midi : EventEmitter
---@field private __send fun(index: number, type: number, data1: number, data2: number, channel: number, cable: number)
---@field private __getNoteId fun(note: number, channel: number)
---@field parseNoteId fun(noteId: number): note: number, channel: number
Midi = _G.Midi or {}
Midi.__events = {}
mixin(Midi, EventEmitter)

---@type { [number]: MidiMessage }
local messageDict = {}

local function defineMidiMessage(type, name, keys)
  local Message = class(MidiMessage) --[=[@as MidiMessage]=]
  Message.type = type
  Message.keys = keys
  Message.name = name
  messageDict[type] = Message
  return Message
end

---@class MidiNoteOn : MidiMessage
---@field note number
---@field velocity number
Midi.NoteOn = defineMidiMessage(0x90, 'noteOn', { 'note', 'velocity' })

---@class MidiNoteOff : MidiMessage
---@field note number
---@field velocity number
Midi.NoteOff = defineMidiMessage(0x80, 'noteOff', { 'note', 'velocity' })

---@class MidiControlChange : MidiMessage
---@field controler number
---@field value number
Midi.ControlChange =
  defineMidiMessage(0xB0, 'controlChange', { 'controler', 'value' })

---@type fun(index: number, type: number, data1: number, data2: number, channel: number, cable: number)
function Midi.handleInput(index, type, data1, data2, channel, cable)
  local Message = messageDict[type]
  if Message == nil then return end

  local message = Message(data1, data2, channel)
  Midi:emit('input', index, message, cable)
end

---@type fun(self, index: number, message: MidiMessage, cable: number)
function Midi:send(index, message, cable)
  local data1, data2 = message:data()
  self.__send(index, message.type, data1, data2, message.channel, cable)
end

---@type fun(self, note: MidiNoteOn | MidiNoteOff)
function Midi:getNoteId(note)
  return Midi.__getNoteId(note.note, note.channel)
end
