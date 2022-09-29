local class = require('class')
local mixin = require('mixin')
local EventEmitter = require('EventEmitter')
local utils = require('utils')

local Module = class()

-- Mixin the event emitter both with and without `__` prefix. This will ensure
-- that the user doesn't accidentally override the event emitter methods, but
-- still be able to use `Module:on()` instead of `Module.__on()`.
mixin(Module, EventEmitter, '__')
mixin(Module, EventEmitter)

function Module:constructor()
  self.__inputs = {}
  self.__outputs = {}
  self.__events = {}

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
