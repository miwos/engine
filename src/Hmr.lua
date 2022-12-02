Hmr = _G.Hmr or {}

---@type fun(modulePath: string): boolean
function Hmr.update(modulePath)
  -- Get the module name and omit die lua root folder.
  local moduleName = string.sub(string.gsub(modulePath, '%/', '.'), 5, -5)

  local oldModule = _LOADED[moduleName]
  local data

  if
    type(oldModule) == 'table' and type(oldModule.__hmrDispose) == 'function'
  then
    data = oldModule.__hmrDispose(oldModule)
  end

  -- Remove the the module from the cache so the new version gets required.
  _LOADED[moduleName] = nil
  local newModule = require(moduleName)

  local isHotReplaced = false
  if
    type(newModule) == 'table' and type(newModule.__hmrAccept) == 'function'
  then
    local shouldDecline = type(newModule.__hmrDecline) == 'function'
      and newModule.__hmrDecline(data, newModule)

    if not shouldDecline then
      newModule.__hmrAccept(data, newModule)
      isHotReplaced = true
    end
  end

  return isHotReplaced
end
