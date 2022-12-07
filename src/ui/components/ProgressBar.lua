local Display = require('ui.components.Display')

---@class ProgressBarProps
---@field x number
---@field y number
---@field width number
---@field height number
---@field value ?number
---@field showScale boolean
---@field scaleStep number

---@class ProgressBar : Component
---@field props ProgressBarProps
local ProgressBar = Miwos.defineComponent('ProgressBar')

function ProgressBar:render()
  return {
    display = Display:define(),
  }
end

function ProgressBar:draw()
  local props = self.props
  local display = self.children.display --[[@as Display]]

  -- Clear
  display:drawRoundedRectangle(
    props.x,
    props.y,
    props.width,
    props.height,
    props.height / 2,
    Display.Color.Black,
    true
  )

  -- Draw the complete filled bar.
  display:drawRoundedRectangle(
    props.x,
    props.y,
    props.width,
    props.height,
    props.height / 2,
    Display.Color.White,
    true
  )

  -- Crop the filled bar to match the value.
  local barWidth = math.floor(props.value * props.width)
  display:drawRectangle(
    props.x + barWidth,
    props.y,
    props.width - barWidth,
    props.height,
    Display.Color.Black,
    true
  )

  -- Add the outline
  display:drawRoundedRectangle(
    props.x,
    props.y,
    props.width,
    props.height,
    self.props.height / 2,
    Display.Color.White,
    false
  )

  -- Optionally, add a scale
  if props.showScale ~= nil then
    -- Omit the first and last scale markers.
    for x = props.scaleStep, props.width, props.scaleStep do
      local color = x < (props.x + barWidth - 1) and Display.Color.Black
        or Display.Color.White
      display:drawLine(x, props.y + 1, x, Display.height - 1, color)
    end
  end

  display:update()
end

ProgressBar:event('prop[value]:change', function(self)
  self:draw()
end)

return ProgressBar
