local Utils = require('Utils')
Hmr = _G.Hmr or {}

---@param modulePath string
---@return boolean
function Hmr.update(modulePath)
  -- Get the module name (without the lua root folder).
  local moduleName = string.sub(string.gsub(modulePath, '%/', '.'), 5, -5)

  local oldModule = _LOADED[moduleName]
  if type(oldModule) == 'table' then
    Utils.callIfExists(oldModule.__hmrDispose)
  end

  -- Remove the the module from the cache so the new version gets required.
  _LOADED[moduleName] = nil
  local newModule = require(moduleName)

  local isHotReplaced = false
  if
    type(newModule) == 'table' and type(newModule.__hmrAccept) == 'function'
  then
    local shouldDecline = type(oldModule) == 'table'
      and Utils.callIfExists(oldModule.__hmrDecline, newModule)

    if not shouldDecline then
      newModule.__hmrAccept(newModule)
      isHotReplaced = true
    end
  end

  return isHotReplaced
end
