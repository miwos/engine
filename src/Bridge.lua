local EventEmitter = require('EventEmitter')

Bridge = _G.Bridge or {}
Bridge.__methods = {}
Bridge.__events = {}

---@param address string
---@return unknown
function Bridge.handleOsc(address, ...)
  -- First call the method, then emit events.
  local method = Bridge.__methods[address]
  local result
  if type(method) == 'function' then result = method(...) end
  EventEmitter.emit(Bridge, address, ...)
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

---@param name string
---@param handler function
function Bridge.on(name, handler)
  EventEmitter.on(Bridge, name, handler)
end

---@param name string
---@param handler function
function Bridge.off(name, handler)
  EventEmitter.off(Bridge, name, handler)
end

---@param name string
---@param handler function
function Bridge.once(name, handler)
  EventEmitter.once(Bridge, name, handler)
end
