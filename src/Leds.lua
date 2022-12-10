Leds = _G.Leds or {}

local onIndexes = {}
local brightness = 32 -- 0-255

function Leds.toggle(index, state)
  if state then
    table.insert(onIndexes, index)
    Leds.write(index, brightness)
  else
    table.remove(onIndexes, index)
    Leds.write(index, 0)
  end
end

function Leds.setBrightness(value)
  brightness = value
  for _, index in ipairs(onIndexes) do
    Leds.write(index, brightness)
  end
end
