local utils = {}

function utils.option(value, default)
  return value == nil and default or value
end

---From https://stackoverflow.com/a/66370080/12207499, thanks PiFace!
function utils.isArray(t)
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
        utils.isArray(t) and serialized
        or serializeKey(key) .. (pretty and ' = ' or '=') .. serialized
      )

    key, value = next(t, key)
    if key then str = str .. (pretty and ', ' or ',') end
  end
  return str .. (pretty and ' }' or '}')
end

function utils.serialize(value, pretty)
  return type(value) == 'table' and serializeTable(value, nil, pretty)
    or serializeValue(value)
end

function utils.indent(depth)
  return string.rep(' ', depth * 2)
end

function utils.maskCurlyBraces(text)
  text = text:gsub('{', '#<#')
  text = text:gsub('}', '#>#')
  return text
end

function utils.pluralize(count, noun, suffix)
  suffix = suffix or 's'
  return noun .. (count > 1 and suffix or '')
end

---@type fun(fn: function, ...: any)
function utils.callIfExists(fn, ...)
  if fn then return fn(...) end
end

function utils.mapValue(value, inMin, inMax, outMin, outMax)
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

function utils.getUsedMemory()
  collectgarbage('collect')
  return collectgarbage('count')
end

return utils
