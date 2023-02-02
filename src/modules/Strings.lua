local Utils = require('Utils')
---@class ModuleStrings : Module
local Strings = Miwos.defineModule('Strings', {
  shape = 'Chord',
  inputs = { 'midi' },
  outputs = { 'midi' },
  props = {
    note = Prop.Number({ value = 24, min = 1, max = 96, step = 1 }),
  },
})

Strings.__hmrKeep = { 'chord', 'chords', 'currentStep' }

function Strings:setup()
  self.lastNoteInTime = 0
  self.maxNoteInterval = 100 -- ms
  self.tuning = { 40, 45, 50, 55, 59, 64 } -- EADGBE
  -- self.tuning = { 38, 45, 50, 55, 57, 62 } --DADGAD

  self.noteInputTimer = nil
  self.scheduleTimer = nil
  self.scheduleInterval = 25 --ms
  self.nextNoteTime = Timer.ticks()
  self.scheduleAheadTime = 4 --ticks

  self.notes = {}
  self.chords = {}
  self.chord = nil

  self.pattern = {
    { 1, 6 },
    4,
    2,
    5,
    3,
    6,
  }
  self.currentStep = 1
  self:schedule()
end

function Strings:schedule()
  self.scheduleTimer = Timer.delay(function()
    local ticks = Timer.ticks()
    while self.nextNoteTime < ticks + self.scheduleAheadTime do
      local strings = Utils.asTable(self.pattern[self.currentStep])

      for _, string in ipairs(strings) do
        local fret = (self.chord and self.chord[string]) or 0
        local pitch = self.tuning[string] + fret
        Timer.scheduleMidi(
          Midi.NoteOn(pitch, 127, 1),
          2,
          1,
          self.nextNoteTime,
          true
        )
      end

      self.nextNoteTime = self.nextNoteTime + self.props.note
      self.currentStep = self.currentStep + 1
      if self.currentStep > #self.pattern then self.currentStep = 1 end
    end

    self:schedule()
  end, self.scheduleInterval * 1000)
end

function Strings:destroy()
  Timer.cancel(self.noteInputTimer)
  Timer.cancel(self.scheduleTimer)
end

Strings:event('input[1]:noteOn', function(self, note)
  ---@cast self ModuleStrings
  ---@cast note MidiNoteOn

  local time = Timer.millis()
  if time - self.lastNoteInTime > self.maxNoteInterval then self.notes = {} end

  self.notes[#self.notes + 1] = note.note
  self.lastNoteInTime = time

  Timer.cancel(self.noteInputTimer)
  self.noteInputTimer = Timer.delay(function()
    self.chords = self:findFrettedChords(self.notes)
    self.chord = self.chords[1]
    Log.dump(self.chord)
  end, self.maxNoteInterval * 1000)
end)

---@param notes table<number>
---@return table
function Strings:findFrettedChords(notes)
  -- All possible locations of each note in the chord, stored as a table
  -- of { string = fret }.
  local notePositions = {}
  for _, notePitch in ipairs(notes) do
    local positions = {}
    local hasPosition = false
    for string, stringPitch in ipairs(self.tuning) do
      local fret = notePitch - stringPitch
      if fret >= 0 and fret <= 12 then
        positions[string] = fret
        hasPosition = true
      end
    end
    if hasPosition then notePositions[#notePositions + 1] = positions end
  end

  -- `frettedChords` will hold the result of `buildFrettedChords()`.
  local frettedChords = {}
  self:buildFrettedChords(notePositions, 1, {}, frettedChords)

  -- Prefer chords that would be easy to pick on a stringed instrument (small
  -- fret span bettwen all notes).
  table.sort(frettedChords, function(a, b)
    return self:getFretSpan(a) < self:getFretSpan(b)
  end)

  return frettedChords
end

function Strings:buildFrettedChords(
  notePositions,
  index,
  currentChord,
  allChords
)
  -- The chord is finished, as we included all notes.
  if index > #notePositions then
    allChords[#allChords + 1] = currentChord
    return
  end

  -- Each note could be played on multiple strings, therefore we have to
  -- recursively walk each possible note position.
  for string, fret in pairs(notePositions[index]) do
    -- On a stringed instrument we can only pick one note per string.
    if currentChord[string] == nil then
      local chordCopy = Utils.copyTable(currentChord)
      chordCopy[string] = fret
      self:buildFrettedChords(notePositions, index + 1, chordCopy, allChords)
    end
  end
end

function Strings:getFretSpan(frettedNotes)
  local lowest, highest = math.huge, 0
  for _, fret in pairs(frettedNotes) do
    if fret > 0 then
      lowest = math.min(lowest, fret)
      highest = math.max(highest, fret)
    end
  end
  return highest - lowest
end

return Strings
