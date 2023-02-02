local Utils = require('Utils')
---@class ModuleDelay : Module
local Delay = Miwos.defineModule('Delay', {
  inputs = { 'midi' },
  outputs = { 'midi' },
  props = {
    feed = Prop.Number({ value = 20, min = 0, max = 100, step = 1 }),
    time = Prop.Number({ value = 500, min = 0, max = 1000, step = 1 }),
    dryWet = Prop.Number({ value = 50, min = 0, max = 100, step = 1 }),
  },
})

function Delay:setup()
  self.messages = {}
  self.timers = {}
  self.mono = true
end

Delay:event('input[1]', function(self, message)
  ---@cast self ModuleDelay
  ---@cast message MidiMessage|MidiNoteOn

  local isNoteOn = message:is(Midi.NoteOn)
  if isNoteOn and self.mono then self:cleanUpNote(message) end

  local dryGain = Utils.dryWetGain(self.props.dryWet / 100)
  self:sendWithGain(message, dryGain)

  local timer
  local gain = 1
  local function delay()
    timer = Timer.delay(function()
      local _, wetGain = Utils.dryWetGain(self.props.dryWet / 100)
      self:sendWithGain(message, gain * wetGain)

      local feed = self.props.feed / 100
      gain = gain * feed
      local thresh = feed * 0.01

      if feed == 0 or gain < thresh then
        Timer.cancel(timer)
      else
        delay()
      end
    end, self.props.time * 1000)

    if isNoteOn then
      ---@cast message MidiNoteOn
      self.timers[Midi:getNoteId(message)] = timer
    end
  end

  delay()
end)

function Delay:sendWithGain(message, gain)
  if gain == 0 then return end

  if message:is(Midi.NoteOn) then
    local velocity = math.floor(message.velocity * gain)
    if velocity == 0 then return end
    message = Midi.NoteOn(message.note, velocity, message.channel)
  end

  self:output(1, message, 1)
end

function Delay:cleanUpNote(note)
  local timer = self.timers[Midi:getNoteId(note)]
  if timer then Timer.cancel(timer) end
  self:output(1, Midi.NoteOff(note.note, 0, note.channel), 1)
end

function Delay:destroy()
  for _, timer in pairs(self.timers) do
    Timer.cancel(timer)
  end
end

return Delay
