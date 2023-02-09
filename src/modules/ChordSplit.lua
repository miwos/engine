local Utils = require('Utils')

---@class ChordSplit : Module
local ChordSplit = Miwos.defineModule('ChordSplit', {
  shape = 'Split',
  inputs = { 'midi' },
  outputs = { 'midi', 'midi' },
  props = {
    notes = Prop.Number({ value = 3, min = 2, max = 10, step = 1 }),
  },
})

function ChordSplit:setup()
  self.notes = {}
  self.noteOutputs = {}
  self.lastNoteTime = 0
  self.maxNoteInterval = 25 -- ms
  self.timer = nil
end

ChordSplit:event('input[1]:noteOn', function(self, note)
  ---@cast self ChordSplit
  ---@cast note MidiNoteOn

  local time = Timer.millis()
  if time - self.lastNoteTime > self.maxNoteInterval then self.notes = {} end

  local noteId = Midi:getNoteId(note)
  self.notes[noteId] = note
  self.lastNoteTime = time

  Timer.cancel(self.timer)
  self.timer = Timer.delay(function()
    self:split()
  end, self.maxNoteInterval * 1000)
end)

ChordSplit:event('input[1]:noteOff', function(self, note)
  ---@cast self ChordSplit
  ---@cast note MidiNoteOn

  local noteId = Midi:getNoteId(note)
  local outputIndex = self.noteOutputs[noteId]
  self.noteOutputs[noteId] = nil

  if outputIndex then
    self:output(outputIndex, note, 1)
  else
    -- If the note is shorter than the maxNoteInterval, is hasn't been send
    -- yet (because the split didn't happen). So instead of sending the noteOff
    -- message we can just remove the note from our list.
    self.notes[noteId] = nil
  end
end)

function ChordSplit:split()
  local notesCount = Utils.getTableLength(self.notes)
  local outputIndex = (notesCount < self.props.notes) and 1 or 2
  self:__finishNotes(outputIndex)

  for id, note in pairs(self.notes) do
    self.noteOutputs[id] = outputIndex
    self:output(outputIndex, note, 1)
  end
end

return ChordSplit
