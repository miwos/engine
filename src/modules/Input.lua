---@class ModuleInput : Module
local Input = Miwos.defineModule('Input', {
  outputs = { 'midi' },
})

function Input:init()
  self.midiInputEventHandler = Midi:on('input', function(...)
    self:handleMidiInput(...)
  end)
end

function Input:handleMidiInput(index, message, cable)
  local isSameDevice = true
  local isSameCable = true
  if isSameDevice and isSameCable then self:output(1, message, cable) end
end

function Input:destroy()
  Midi:off('input', self.midiInputEventHandler)
end

return Input
