local NumberField = require('ui.components.NumberField')
local PropsView = Miwos.defineComponent('PropsView')

function PropsView:render()
  return {
    NumberField:define({
      value = 0,
      min = 0,
      max = 12,
      showScale = true,
      step = 1,
    }, { slot = 1 }),
    NumberField:define({
      value = 0,
      min = 0,
      max = 12,
      showScale = true,
      step = 1,
    }, { slot = 2 }),
    NumberField:define({
      value = 0,
      min = 0,
      max = 12,
      showScale = true,
      step = 1,
    }, { slot = 3 }),
  }
end

return PropsView
