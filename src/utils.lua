---@diagnostic disable: undefined-field
---@class Utils
---@field packBytes fun(byte1: number, byte2: number, byte3?: number, byte4?: number): number
---@field unpackBytes fun(packed: number): number, number, number, number
---@field setBit fun(number: number, bitIndex: number, value: boolean)
local Utils = _G.Utils or {}

function Utils.option(value, default)
  return value == nil and default or value
end

---From https://stackoverflow.com/a/66370080/12207499, thanks PiFace!
function Utils.isArray(t)
  return type(t) == 'table' and #t > 0 and next(t, #t) == nil
end

local function serializeValue(value)
  local valueType = type(value)

  if valueType == 'string' then
    return string.format("'%s'", value)
  elseif valueType == 'boolean' or valueType == 'number' then
    return tostring(value)
  else
    return string.format("'#%s#'", valueType)
  end
end

local function serializeKey(key)
  local keyType = type(key)

  if type(key) == 'string' then
    local isValidIdentifier = key:match('^[%a_][%a%d_]*$')
    return isValidIdentifier and key or string.format("['%s']", key)
  elseif keyType == 'boolean' or keyType == 'number' then
    return string.format('[%s]', tostring(key))
  else
    return string.format("['#%s#']", tostring(keyType))
  end
end

---Based on https://stackoverflow.com/a/64796533/12207499, thanks Francisco!
local function serializeTable(t, done, pretty)
  done = done or {}
  done[t] = true

  local str = pretty and '{ ' or '{'
  local key, value = next(t, nil)
  while key do
    local serialized
    if type(value) == 'table' and not done[value] then
      done[value] = true
      serialized = serializeTable(value, done, pretty)
      done[value] = nil
    else
      serialized = serializeValue(value)
    end

    str = str
      .. (
        Utils.isArray(t) and serialized
        or serializeKey(key) .. (pretty and ' = ' or '=') .. serialized
      )

    key, value = next(t, key)
    if key then str = str .. (pretty and ', ' or ',') end
  end
  return str .. (pretty and ' }' or '}')
end

function Utils.serialize(value, pretty)
  return type(value) == 'table' and serializeTable(value, nil, pretty)
    or serializeValue(value)
end

function Utils.indent(depth)
  return string.rep(' ', depth * 2)
end

function Utils.maskCurlyBraces(text)
  text = text:gsub('{', '#<#')
  text = text:gsub('}', '#>#')
  return text
end

function Utils.pluralize(count, noun, suffix)
  suffix = suffix or 's'
  return noun .. (count > 1 and suffix or '')
end

---@type fun(fn: function, ...: any)
function Utils.callIfExists(fn, ...)
  if fn then return fn(...) end
end

function Utils.mapValue(value, inMin, inMax, outMin, outMax)
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function Utils.getUsedMemory()
  collectgarbage('collect')
  return collectgarbage('count')
end

function Utils.capitalize(str)
  return str:sub(1, 1):upper() .. str:sub(2)
end

function Utils.dryWetGain(dryWet)
  if dryWet == 0.5 then
    return 1, 1
  elseif dryWet < 0.5 then
    return 1, dryWet * 2
  elseif dryWet > 0.5 then
    return (1 - dryWet) * 2, 1
  end
end

function Utils.copyTable(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

function Utils.asTable(value)
  return type(value) == 'table' and value or { value }
end

function Utils.getTableLength(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function Utils.throttle(fn, interval)
  local lastTime = 0

  return function(...)
    local args = { ... }
    local now = Timer.micros()

    local function next()
      lastTime = now
      fn(unpack(args))
    end

    if lastTime and now < lastTime + interval then
      Timer.cancel(next)
      Timer.schedule(next, now + interval)
    else
      lastTime = now
      next()
    end
  end
end

return Utils
