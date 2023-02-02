local Display = require('ui.components.Display')
local Encoder = require('ui.components.Encoder')
local Utils = require('Utils')

---@class ListProps
---@field values string

---@class List : Component
---@field props ListProps
local List = Miwos.defineComponent('List')

function List:setup()
  self.index = 1
  local ticksPerValue = 5
  self.encoderMax = #self.props.values * ticksPerValue
end

function List:render()
  return { display = Display(), encoder = Encoder() }
end

function List:mount()
  local encoder = self.children.encoder --[=[@as Encoder]=]
  encoder:setRange(0, self.encoderMax)
  encoder:write(0)
  self:draw()
end

function List:draw()
  local props = self.props
  local display = self.children.display --[=[@as Display]=]

  -- Clear
  display:drawRectangle(
    0,
    0,
    Display.width,
    Display.height,
    Display.Color.Black,
    true
  )

  display:text(props.values[self.index], Display.Color.White)
  display:update()
end

List:event('encoder:change', function(self, rawValue)
  local index = math.floor(
    Utils.mapValue(rawValue, 0, self.encoderMax, 1, #self.props.values)
  )
  if index == self.index then return end

  self.index = index
  self:draw()
end)

List:event('encoder:click', function(self)
  ---@cast self List
  self:emit('select', self.props.values[self.index])
end)

return List
