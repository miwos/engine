local class = require('class')
local Utils = require('utils')

---@class Modulator : Class
---@field __definition ModulatorDefinition
---@field value fun(self: Modulator, time: number): number
---@field setup function | nil
---@field destroy function | nil
local Modulator = class()

function Modulator:constructor(props)
  self.__inputs = {}
  self.__outputs = {}
  self.__activeNotes = {}
  self.props = Utils.getPropsWithDefaults(self.__definition.props, props or {})

  Utils.callIfExists(self.setup, self)
end

return Modulator
