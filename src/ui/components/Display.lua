---@class DisplayProps
---@field index ?number

---@class Display : Component
---@field props DisplayProps
local Display = Miwos.defineComponent('Display')

---@enum Color
Display.Color = {
  Black = 0,
  White = 1,
}

Display.width = 128
Display.height = 32

function Display:setup()
  self.index = self.props.index or self.ctx.slot
end

---@param text string
---@param color Color
function Display:text(text, color)
  Displays.text(self.index, text, color)
end

---@param x number
---@param y number
---@param color Color
function Display:drawPixel(x, y, color)
  Displays.drawPixel(self.index, x, y, color)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param color Color
function Display:drawLine(x1, y1, x2, y2, color)
  Displays.drawLine(self.index, x1, y1, x2, y2, color)
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@param color Color
---@param fill boolean
function Display:drawTriangle(x1, y1, x2, y2, x3, y3, color, fill)
  Displays.drawTriangle(self.index, x1, y1, x2, y2, x3, y3, color, fill)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param color Color
---@param fill boolean
function Display:drawRectangle(x, y, width, height, color, fill)
  Displays.drawRectangle(self.index, x, y, width, height, color, fill)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param radius number
---@param color Color
---@param fill boolean
function Display:drawRoundedRectangle(x, y, width, height, radius, color, fill)
  Displays.drawRoundedRectangle(
    self.index,
    x,
    y,
    width,
    height,
    radius,
    color,
    fill
  )
end

---@param x number
---@param y number
---@param radius number
---@param color Color
---@param fill boolean
function Display:drawCircle(x, y, radius, color, fill)
  Displays.drawCircle(self.index, x, y, radius, color, fill)
end

function Display:clear()
  Displays.clear(self.index)
end

function Display:update()
  Displays.update(self.index)
end

return Display
