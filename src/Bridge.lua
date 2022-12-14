local EventEmitter = require('EventEmitter')
local mixin = require('mixin')

Bridge = _G.Bridge or {}
Bridge.__methods = {}
Bridge.__events = {}
mixin(Bridge, EventEmitter)

---@type fun(address: string, ...: any): unknown
function Bridge.handleOsc(address, ...)
  -- First call the method, then emit events.
  local method = Bridge.__methods[address]
  local result
  if type(method) == 'function' then result = method(...) end
  Bridge:emit(Bridge, address, ...)
  return result
end

---@type fun(name: string, handler: function)
function Bridge.addMethod(name, handler)
  if Bridge.__methods[name] then
    Log.warn(string.format('Bridge method `%s` already exists', name))
    return
  end
  Bridge.__methods[name] = handler
end
