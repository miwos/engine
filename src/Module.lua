local class = require('class')
local EventEmitter = require('EventEmitter')
local utils = require('utils')

---@class Module : Class, EventEmitter
---@field init function | nil
local Module = class(EventEmitter)

function Module:constructor()
  self.__inputs = {}
  self.__outputs = {}

  utils.callIfExists(self.init, self)
end

---@param outputIndex number
---@param moduleId number
---@param inputIndex number
function Module:__connect(outputIndex, moduleId, inputIndex)
  self.__outputs[outputIndex] = self.__outputs[outputIndex] or {}
  table.insert(self.__outputs[outputIndex], { moduleId, inputIndex })
end

---@param outputIndex number
---@param moduleId number
---@param inputIndex number
function Module:__disconnect(outputIndex, moduleId, inputIndex)
  for index, connection in pairs(self.__outputs[outputIndex] or {}) do
    if connection[0] == moduleId and connection[1] == inputIndex then
      connection[index] = nil
      return
    end
  end
end

---@param outputId number
---@param message any
function Module:output(outputId, message)
  local outputs = self.__outputs[outputId]
  if not outputs then return end
end

return Module
