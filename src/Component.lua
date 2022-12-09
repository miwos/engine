local class = require('class')
local utils = require('utils')

---@class Component : Class
---@field __events { [string]: function }
---@field name string
---@field parent Component | nil
---@field setup function | nil
---@field render function | nil
---@field mount function | nil
---@field unmount function | nil
local Component = class()

function Component:define(props, ctx)
  return { self, props or {}, ctx }
end

function Component:event(name, callback)
  self.__events[name] = callback
end

function Component:dispatch(name, ...)
  utils.callIfExists(self.__events[name], self, ...)
end

function Component:emit(name, ...)
  if not self.parent then return end
  local event = self.name .. ':' .. name
  self.parent:dispatch(event, ...)
end

function Component:setProp(key, value)
  self.props[key] = value
  self:dispatch('prop[' .. key .. ']:change', value)
end

function Component:constructor(props, ctx)
  self.props = props or {}
  self.ctx = ctx
end

function Component:__mount()
  utils.callIfExists(self.setup, self)

  Log.info('mount')

  self.children = utils.callIfExists(self.render, self) or {}
  for name, child in pairs(self.children) do
    child.ctx = child.ctx or self.ctx
    child.parent = self
    child.name = name
    child:__mount()
  end

  utils.callIfExists(self.mount, self)
end

function Component:__unmount()
  for _, child in pairs(self.children) do
    child:__unmount()
  end
  utils.callIfExists(self.unmount, self)
end

return Component
