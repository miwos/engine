local Number = require('ui.components.Number')
local Utils = require('utils')

Prop = {}

setmetatable(Prop, {
  __index = function(_, name)
    local component = Miwos.propDefinitions[name].component
    return function(options, ...)
      -- Lua objects don't have an order (which we need to diplay the props in
      -- the app). We could use an array instead, but it would be more verbose.
      -- As a workaround we use a global counter `__propIndex` that is increased
      -- with each `Prop.<name>()` and is reset in `Miwos.defineComponent()`.
      if _G.__propIndex == nil then _G.__propIndex = 1 end
      options = options == nil and {} or options
      options.index = _G.__propIndex
      _G.__propIndex = _G.__propIndex + 1

      return component:define(options, ...)
    end
  end,
})

---@class Prop
---@field Number fun(props: NumberProps)
Miwos.defineProp('Number', {
  component = Number,
  modulateValue = function(value, modulation, amount, options)
    return Utils.mapValue(modulation, 0, 1, options.min, options.max)
  end,
})
