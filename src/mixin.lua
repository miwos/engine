---@param destination table
---@param source table
---@return table
local function mixin(destination, source)
  for k, v in pairs(source) do
    destination[k] = v
  end
  return destination
end

return mixin
