local mixin = require('mixin')
local EventEmitter = require('EventEmitter')

Encoders = _G.Encoders or {}
mixin(Encoders, EventEmitter)

function Encoders.handleChange(index, value)
  Encoders:emit('change', index, value)
end
