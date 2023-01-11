-- Type annotations only, no need to require this file.

-- https://github.com/miwos/firmware/blob/main/include/LuaDisplays.h
---@class Displays
---@field text fun(index: number, text: string, color: Color)
---@field drawPixel fun(index: number, x: number, y: number, color: Color)
---@field drawLine fun(index: number, x0: number, y0: number, x1: number, y1: number, color: Color)
---@field drawTriangle fun(index: number, x0: number, y0: number, x1: number, y1: number, x2: number, y2: number, color: Color, fill: boolean)
---@field drawRectangle fun(index: number, x: number, y: number, width: number, height: number, color: Color, fill: boolean)
---@field drawRoundedRectangle fun(index: number, x: number, y: number, width: number, height: number, radius: number, color: Color, fill: boolean)
---@field drawCircle fun(index: number, x: number, y: number, radius: number, color: Color, fill: boolean)
---@field update fun(index: number)
---@field clear fun(index: number)
Displays = {}
