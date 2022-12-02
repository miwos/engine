local class = require('class')

---@class MidiMessage: Class
---@field type number The midi type
---@field name string A human readable midi type name (e.g.: 'noteOn')
---@field owner number The id of the instance that created the message
---@field channel number The midi channel
---@field keys table Name aliases for midi data1 and data2 (e.g.: for a noteOn
---this would be: 'note', 'velocity')
local MidiMessage = class()

---@type fun(self, data1: number, data2: number, channel: number)
function MidiMessage:constructor(data1, data2, channel)
  self[self.keys[1]] = data1
  self[self.keys[2]] = data2
  self.channel = channel
end

function MidiMessage:data()
  return self[self.keys[1]], self[self.keys[2]]
end

function MidiMessage:copy()
  local data1, data2 = self:data()
  local copy = self.Class(data1, data2, self.channel) --[[@as MidiMessage]]
  return copy
end

function MidiMessage:is(MidiMessageClass)
  return self.type == MidiMessageClass.type
end

return MidiMessage
