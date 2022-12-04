local class = require('class')

---@class Display : Class
Display = class()

---@enum Color
Display.Color = {
  Black = 0,
  White = 1,
}

---@type fun(self, index: number)
function Display:constructor(index)
  self.index = index
end

---@type fun(self, text: string, color: Color)
function Display:text(text, color)
  Displays.text(self.index, text, color)
end

---@type fun(self, x: number, y: number, color: Color)
function Display:drawPixel(x, y, color)
  Displays.drawPixel(self.index, x, y, color)
end

---@type fun(self, x1: number, y1: number, x2: number, y2: number, color: Color)
function Display:drawLine(x1, y1, x2, y2, color)
  Displays.drawLine(self.index, x1, y2, x2, y2, color)
end

---@type fun(self, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, color: Color, fill: boolean)
function Display:drawTriangle(x1, y1, x2, y2, x3, y3, color, fill)
  Displays.drawTriangle(self.index, x1, y1, x2, y2, x3, y3, color, fill)
end

---@type fun(self, x: number, y: number, width: number, height: number, color: Color, fill?: boolean)
function Display:drawRectangle(x, y, width, height, color, fill)
  Displays.drawRectangle(self.index, x, y, width, height, color, fill)
end

---@type fun(self, x: number, y: number, width: number, height: number, radius: number, color: Color, fill: boolean)
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

---@type fun(self, x: number, y: number, radius: number, color: Color, fill: boolean)
function Display:drawCircle(x, y, radius, color, fill)
  Displays.drawCircle(self.index, x, y, radius, color, fill)
end

function Display:clear()
  Displays.clear(self.index)
end

function Display:update()
  Displays.update(self.index)
end
