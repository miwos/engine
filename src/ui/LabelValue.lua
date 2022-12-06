local class = require('class')
local option = require('utils').option

---@class LabelValue : Class
local LabelValue = class()

---@class LabelValueOptions
---@field x number
---@field y number
---@field width number
---@field height number
---@field value unknown
---@field label string
---@field valueViewDuration number
---@field before string?
---@field after string?

---@enum
LabelValue.Views = { Label = 1, Value = 2 }

---@type fun(self, display: Display, options: LabelValueOptions)
function LabelValue:constructor(display, options)
  self.display = display
  self.x = options.x
  self.y = options.y
  self.width = options.width
  self.height = options.height
  self.label = options.label
  self.before = option(options.before, '')
  self.after = option(options.after, '')
  self.valueViewDuration = option(options.valueViewDuration, 3000)
  self.view = self.Views.Label
end

function LabelValue:render()
  -- Clear
  self.display:drawRectangle(
    self.x,
    self.y,
    self.width,
    self.height,
    Display.Color.Black,
    true
  )

  local text = self.view == self.Views.Label and self.label
    or self.before .. self.value .. self.after

  self.display:text(text, Display.Color.White)
  self.display:update()
end

function LabelValue:update(key, value)
  if key == 'value' then
    self.value = value
    self.view = self.Views.Value
    self:render()

    self.viewTimer = Timer.delay(function()
      self.view = self.Views.Label
      self:render()
    end, self.valueViewDuration * 1000)
  end
end

function LabelValue:destroy()
  Timer.cancel(self.viewTimer)
end

return LabelValue
