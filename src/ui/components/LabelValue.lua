local option = require('Utils').option
local Display = require('ui.components.Display')

---@class LabelValueProps
---@field x number
---@field y number
---@field width number
---@field height number
---@field value unknown
---@field label string
---@field valueViewDuration number
---@field before string?
---@field after string?

---@class LabelValue : Component
---@field props LabelValueProps
local LabelValue = Miwos.defineComponent('LabelValue')

---@enum
LabelValue.Views = { Label = 1, Value = 2 }

function LabelValue:setup()
  self.view = self.Views.Label
  self.viewTimer = nil
end

function LabelValue:render()
  return { display = Display() }
end

function LabelValue:mount()
  self:draw()
end

function LabelValue:draw()
  local props = self.props
  local display = self.children.display --[=[@as Display]=]

  -- Clear
  display:drawRectangle(
    props.x,
    props.y,
    props.width,
    props.height,
    Display.Color.Black,
    true
  )

  -- Show value or label
  local text = self.view == self.Views.Label and props.label
    or option(props.before, '')
      .. option(props.value, 0)
      .. option(props.after, '')
  display:text(text, Display.Color.White)

  display:update()
end

LabelValue:event('prop[value]:change', function(self)
  ---@cast self LabelValue
  self.view = self.Views.Value
  self:draw()
  Timer.cancel(self.viewTimer)

  self.viewTimer = Timer.delay(function()
    self.view = self.Views.Label
    self:draw()
  end, option(self.props.valueViewDuration, 1000) * 1000)
end)

function LabelValue:unmount()
  Timer.cancel(self.viewTimer)
end

return LabelValue
