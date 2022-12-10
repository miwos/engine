local Number = require('ui.components.Number')

---@class Prop
---@field list table<string, Component>
Prop = { list = {} }

setmetatable(Prop, {
  __index = function(_, name)
    local component = Prop.list[name]
    return function(...)
      return component:define(...)
    end
  end,
})

---@class Prop
---@field Number fun(props: NumberProps)
Miwos.defineProp('Number', Number)
