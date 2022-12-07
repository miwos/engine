---@type fun(destination: table, source: table): table
local function mixin(destination, source)
  for k, v in pairs(source) do
    destination[k] = v
  end
  return destination
end

return mixin
