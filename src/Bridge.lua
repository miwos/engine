local EventEmitter = require('EventEmitter')
local mixin = require('mixin')

---@class Bridge: EventEmitter
---@field notify fun(address: string, ...: number | boolean | string)
Bridge = _G.Bridge or {}
Bridge.__methods = {}
Bridge.__events = {}
mixin(Bridge, EventEmitter)

---@param address any
---@param ... any
---@return unknown
function Bridge.handleOsc(address, ...)
  -- First call the method, then emit events.
  local method = Bridge.__methods[address]
  local result
  if type(method) == 'function' then result = method(...) end
  Bridge:emit(address, ...)
  return result
end

---@param name string
---@param handler function
function Bridge.addMethod(name, handler)
  if Bridge.__methods[name] then
    Log.warn(string.format('Bridge method `%s` already exists', name))
    return
  end
  Bridge.__methods[name] = handler
end
