---@class ModuleOutput : Module
local Output = Miwos.defineModule('Output', {
  inputs = { 'midi' },
})

Output:on('prop:beforeChange', function(self)
  -- Finish the notes *before* either `device` or `cable` has changed, so we can
  -- send all unfinished notes to their correct location.
  self:__finishNotes()
end)

Output:on('input', function(self, message)
  self:output(1, message)
end)

---Override `Module.__handleOutput()` to send the message directly via midi.
---@param message MidiMessage
function Output:__handleOutput(_, _, message)
  Midi:send(1, message, 1)
end

return Output
