local Utils = require('utils')
local Lfo = Miwos.defineModulator('Lfo', {
  props = {
    shape = Prop.Number({ value = 1, min = 1, max = 1, step = 1 }),
    rate = Prop.Number({ value = 4, min = 0, max = 10 }),
  },
})

function Lfo:setup()
  -- self.props
end

function Lfo:value(time)
  return Utils.mapValue(math.sin(time / 1000000), -1, 1, 0, 1)
end
