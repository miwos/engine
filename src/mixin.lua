---Add all properties and methods of source to destination.
---@param destination table
---@param source table
---@param prefix? string
local function mixin(destination, source, prefix)
  for k, v in pairs(source) do
    local key = prefix ~= nil and prefix .. k or k
    destination[key] = v
  end
end

return mixin
