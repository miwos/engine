local mixin = require('mixin')
local EventEmitter = require('EventEmitter')

Buttons = _G.Buttons or {}
mixin(Buttons, EventEmitter)

function Buttons.handleClick(index, duration)
  Buttons:emit('click', index, duration)
end
