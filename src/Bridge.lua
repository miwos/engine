local EventEmitter = require('EventEmitter')

Bridge = _G.Bridge or {}
Bridge.__methods = {}
Bridge.__events = {}

function Bridge.handleOsc(address, ...)
  -- First call the method, then emit events.
  local method = Bridge.__methods[address]
  local result
  if type(method) == 'function' then
    result = method(...)
  end
  EventEmitter.emit(Bridge, address, ...)
  return result
end

function Bridge.addMethod(name, handler)
  if Bridge.__methods[name] then
    Log.warn(string.format('Bridge method `%s` already exists', name))
    return
  end
  Bridge.__methods[name] = handler
end

function Bridge.on(name, handler)
  EventEmitter.on(Bridge, name, handler)
end

function Bridge.off(name, handler)
  EventEmitter.off(Bridge, name, handler)
end

function Bridge.once(name, handler)
  EventEmitter.once(Bridge, name, handler)
end
