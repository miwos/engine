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

function Module:__connect(outputId, moduleId, inputId)
  self.__outputs[outputId] = self.__outputs[outputId] or {}
  table.insert(self.__outputs[outputId], { moduleId, inputId })
end

function Module:output(outputId, message)
  local outputs = self.__outputs[outputId]
  if not outputs then
    return
  end
end

return Module
