local mixin = require('mixin')
local EventEmitter = require('EventEmitter')

Buttons = _G.Buttons or {}
Buttons.__events = {}
mixin(Buttons, EventEmitter)

function Buttons.handleClick(index, duration)
  Buttons:emit('click', index, duration)
  if index >= 7 and index <= 9 then Encoders:emit('click', index - 6) end
end
