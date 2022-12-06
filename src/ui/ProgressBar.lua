local class = require('class')

---@class ProgressBar : Class
local ProgressBar = class()

---@class ProgressBarOptions
---@field x number
---@field y number
---@field width number
---@field height number

---@type fun(self, display: Display, options: ProgressBarOptions)
function ProgressBar:constructor(display, options)
  self.display = display
  self.x = options.x
  self.y = options.y
  self.width = options.width
  self.height = options.height
  self.radius = self.height / 2
  self.value = 0
  self:render()
end

function ProgressBar:clear()
  self.display:drawRoundedRectangle(
    self.x,
    self.y,
    self.width,
    self.height,
    self.radius,
    Display.Color.Black,
    true
  )
end

function ProgressBar:render()
  -- Draw the complete filled bar.
  self.display:drawRoundedRectangle(
    self.x,
    self.y,
    self.width,
    self.height,
    self.radius,
    Display.Color.White,
    true
  )

  -- Crop the filled bar to match the value.
  local cropWidth = math.ceil(self.width * (1 - self.value))
  self.display:drawRectangle(
    self.x + self.width - cropWidth,
    self.y,
    cropWidth,
    self.height,
    Display.Color.Black,
    true
  )

  -- Add the outline
  self.display:drawRoundedRectangle(
    self.x,
    self.y,
    self.width,
    self.height,
    self.radius,
    Display.Color.White,
    false
  )

  self.display:update()
end

function ProgressBar:update(key, value)
  self:clear()
  self[key] = value
  self:render()
end

return ProgressBar
