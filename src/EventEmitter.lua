local Utils = require('Utils')

---@class EventEmitter
---@field __events table
EventEmitter = {}

---@param event string
---@param callback function
---@return function callback
function EventEmitter:on(event, callback)
  self.__events[event] = self.__events[event] or {}
  table.insert(self.__events[event], callback)
  return callback
end

---@param event string
---@param callback function
function EventEmitter:off(event, callback)
  local handlers = self.__events[event]

  for i = 1, #handlers do
    if handlers[i] == callback then table.remove(handlers, i) end
  end

  if #handlers == 0 then handlers[event] = nil end
end

--TODO: remove as we don't seem to use it
---@param event string
---@param callback function
function EventEmitter:once(event, callback)
  local function handler()
    self:off(event, handler)
    callback()
  end
  self:on(event, handler)
end

---@param event string
---@param ... unknown
function EventEmitter:emit(event, ...)
  local handlers = self.__events[event]
  if handlers ~= nil then
    for i = 1, #handlers do
      -- An event handler might alter the handlers list by calling `off()` so
      -- we have to assume that the handler might be nil.
      Utils.callIfExists(handlers[i], ...)
    end
  end
end

return EventEmitter
