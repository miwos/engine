local utils = require('utils')
local option = utils.option

local function ease(x)
  return 1.383493
    + (0.00001915815 - 1.383493) / (1 + (x / 0.3963062) ^ 1.035488)
end

---@class PropNumber : Class, EventEmitter
local PropNumber = Miwos.defineProp('Number')

---@class PropNumberOptions
---@field min ?number
---@field max ?number

---@type fun(self, name: string, value: number, options: PropNumberOptions)
function PropNumber:constructor(name, value, options)
  self.min = option(options.min, 0)
  self.max = option(options.max, 127)
  self.encoderMin = 0
  self.encoderMax = 127
end

function PropNumber:mount(display, encoder)
  self.diplay = Display
  encoder.setRange(self.encoderMin, self.encoderMax)
  encoder.write(self.value)
end

PropNumber:on('encoder:change', function(self, rawValue)
  self.value = self:decodeValue(rawValue)
end)

function PropNumber:decodeValue(rawValue)
  local scaledValue = utils.mapValue(
    rawValue,
    self.encoderMin,
    self.encoderMax,
    self.min,
    self.max
  )
end

return PropNumber
