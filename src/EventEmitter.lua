local utils = require('utils')

---@class EventEmitter
---@field __events table
EventEmitter = {}

---@type fun(self, event: string, callback: function): function
function EventEmitter:on(event, callback)
  self.__events[event] = self.__events[event] or {}
  table.insert(self.__events[event], callback)
  return callback
end

---@type fun(self, event: string, callback: function)
function EventEmitter:off(event, callback)
  local handlers = self.__events[event]

  for i = 1, #handlers do
    if handlers[i] == callback then table.remove(handlers, i) end
  end

  if #handlers == 0 then handlers[event] = nil end
end

---@type fun(self, event: string, callback: function)
function EventEmitter:once(event, callback)
  local function handler()
    self:off(event, handler)
    callback()
  end
  self:on(event, handler)
end

---@type fun(self, event: string, ...: unknown)
function EventEmitter:emit(event, ...)
  local handlers = self.__events[event]
  if handlers ~= nil then
    for i = 1, #handlers do
      -- An event handler might alter the handlers list by calling `off()` so
      -- we have to assume that the handler might be nil.
      utils.callIfExists(handlers[i], ...)
    end
  end
end

return EventEmitter
