local class = require('class')
local Utils = require('Utils')

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

function Component:callEvent(name, ...)
  Utils.callIfExists(self.__events[name], self, ...)
end

function Component:emit(name, ...)
  if not self.parent then return end
  local event = self.name .. ':' .. name
  self.parent:callEvent(event, ...)
end

function Component:setProp(key, value)
  self.props[key] = value
  self:callEvent('prop[' .. key .. ']:change', value)
end

function Component:constructor(props, ctx)
  self.props = props or {}
  self.ctx = ctx
end

function Component:__mount()
  Utils.callIfExists(self.setup, self)

  self.children = Utils.callIfExists(self.render, self) or {}
  for name, child in pairs(self.children) do
    self:addChild(name, child)
  end

  Utils.callIfExists(self.mount, self)
end

function Component:addChild(name, child)
  child.ctx = child.ctx or self.ctx
  child.parent = self
  child.name = name
  child:__mount()
  self.children[name] = child
end

function Component:removeChild(child)
  child:__unmount()
  self.children[child.name] = nil
end

function Component:__unmount()
  for _, child in pairs(self.children) do
    self:removeChild(child)
  end
  Utils.callIfExists(self.unmount, self)
end

return Component
