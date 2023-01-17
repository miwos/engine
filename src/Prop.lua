local Number = require('ui.components.Number')

---@class Prop
---@field list table<string, Component>
Prop = { list = {} }

setmetatable(Prop, {
  __index = function(_, name)
    local component = Prop.list[name]
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
Miwos.defineProp('Number', Number)
