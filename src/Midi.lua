local class = require('class')
local EventEmitter = require('EventEmitter')
local MidiMessage = require('MidiMessage')
local mixin = require('mixin')
local Utils = require('Utils')

---@class Midi : EventEmitter
---@field private __send fun(index: number, type: number, data1: number, data2: number, channel: number, cable: number)
---@field start fun()
---@field stop fun()
---@field setTempo fun(bpm: number)
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

---@param index number
---@param type number
---@param data1 number
---@param data2 number
---@param channel number
---@param cable number
function Midi.handleInput(index, type, data1, data2, channel, cable)
  local Message = messageDict[type]
  if Message == nil then return end

  local message = Message(data1, data2, channel)
  Midi:emit('input', index, message, cable)
end

function Midi.handleClock(tick)
  -- Midi:send(1, Midi.NoteOn(62, 127, 1), 1)
end

---@param index number
---@param message MidiMessage
---@param cable number
function Midi:send(index, message, cable)
  local data1, data2 = message:data()
  self.__send(index, message.type, data1, data2, message.channel, cable)
end

---@param note MidiNoteOn | MidiNoteOff
---@return number
function Midi:getNoteId(note)
  return Utils.packBytes(note.note, note.channel)
end

---@param id number
---@return number, number
function Midi:parseNoteId(id)
  local note, channel = Utils.unpackBytes(id)
  return note, channel
end
