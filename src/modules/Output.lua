---@class ModuleOutput : Module
local Output = Miwos.defineModule('Output', {
  inputs = { 'midi' },
  props = {
    device = Prop.Number({ min = 1, max = 13, step = 1 }),
  },
})

Output:event('prop:beforeChange', function(self)
  -- Finish the notes *before* either `device` or `cable` has changed, so we can
  -- send them to their correct location.
  self:__finishNotes()
end)

Output:event('input[1]', function(self, message)
  self:output(1, message)
end)

---Override `Module.__output()` to send the message directly via midi.
---@type fun(self, _, message: MidiMessage)
function Output:__output(_, message)
  Midi:send(self.props.device, message, 1)
end

return Output
