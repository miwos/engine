---@class ModuleInput : Module
local Input = Miwos.defineModule('Input', {
  outputs = { 'midi' },
  label = false,
  props = {
    device = Prop.Number({
      listed = false,
      value = 4,
      min = 1,
      max = 13,
      step = 1,
    }),
    cable = Prop.Number({
      listed = false,
      value = 1,
      min = 1,
      max = 16,
      step = 1,
    }),
  },
})

function Input:setup()
  self.midiInputEventHandler = Midi:on('input', function(...)
    self:handleMidiInput(...)
  end)
end

function Input:handleMidiInput(device, message, cable)
  local isSameDevice = device == self.props.device
  local isSameCable = cable == self.props.cable
  if isSameDevice and isSameCable then self:output(1, message, cable) end
end

Input:event('prop:beforeChange', function(self)
  -- Finish the notes *before* either `device` or `cable` has changed, so we can
  -- send them to their correct location.
  self:__finishNotes()
end)

function Input:destroy()
  Midi:off('input', self.midiInputEventHandler)
end

return Input
