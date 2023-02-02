---@class ModuleChord : Module
local Chord = Miwos.defineModule('Chord', {
  inputs = { 'midi' },
  outputs = { 'midi' },
  props = {
    pitch1 = Prop.Number({ value = 6, min = -12, max = 12, step = 1 }),
    pitch2 = Prop.Number({ value = 0, min = -12, max = 12, step = 1 }),
    pitch3 = Prop.Number({ value = 0, min = -12, max = 12, step = 1 }),
  },
})

function Chord:setup()
  self.chords = {}
end

Chord:event('input[1]:noteOn', function(self, note)
  ---@cast self ModuleChord
  ---@cast note MidiNoteOn
  self:output(1, note, 1)
  local id = Midi:getNoteId(note)
  local chord = {}
  self.chords[id] = chord
  for i = 1, 3 do
    local pitch = self.props['pitch' .. i]
    local message = Midi.NoteOn(note.note + pitch, note.velocity, note.channel)
    self:output(1, message, 1)
    id = Midi:getNoteId(message)
    chord[#chord + 1] = id
  end
end)

Chord:event('input[1]:noteOff', function(self, note)
  ---@cast self ModuleChord

  self:output(1, note, 1)
  local id = Midi:getNoteId(note)
  local chord = self.chords[id]
  if not chord then
    self:__finishNotes(1)
    Log.warn("couldn't finish chord")
    return
  end

  for _, id in ipairs(chord) do
    local note, channel = Midi:parseNoteId(id)
    self:output(1, Midi.NoteOff(note, 0, channel))
  end
end)

return Chord
