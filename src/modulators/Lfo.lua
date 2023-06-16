local Utils = require('utils')
local Lfo = Miwos.defineModulator('Lfo', {
  bipolar = true,
  props = {
    shape = Prop.Number({ value = 1, min = 1, max = 1, step = 1 }),
    rate = Prop.Number({ value = 4, min = 0, max = 10 }),
  },
})

function Lfo:setup()
  -- self.props
  -- Log.dump(self.props)
end

function Lfo:value(time)
  local timeSeconds = time / 1000000
  local angularFrequency = 2 * math.pi * self.props.rate
  return math.sin(timeSeconds * angularFrequency)
end
