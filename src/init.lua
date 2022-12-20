require('Bridge')
require('Buttons')
require('Encoders')
require('Hmr')
require('Leds')
require('Log')
require('Midi')
require('Miwos')
require('Prop')
require('Timer')
local utils = require('utils')

require('modules.Input')
require('modules.Output')

local PropsView = require('ui.views.PropsView')
local MenuView = require('ui.views.MenuView')

Bridge.addMethod('/e/modules/add', function(...)
  return Miwos.patch:addModule(...)
end)

Bridge.addMethod('/e/modules/remove', function(...)
  return Miwos.patch:removeModule(...)
end)

Bridge.addMethod(
  '/e/connections/add',
  function(fromId, outputIndex, toId, inputIndex)
    local fromModule = Miwos.patch.modules[fromId]
    fromModule:__connect(outputIndex, toId, inputIndex)
  end
)

Bridge.addMethod(
  '/e/connections/remove',
  function(fromId, outputIndex, toId, inputIndex)
    local fromModule = Miwos.patch.modules[fromId]
    fromModule:__disconnect(outputIndex, toId, inputIndex)
  end
)

Bridge.addMethod('/e/modules/definitions', function()
  local definitions = {}
  local files = FileSystem.listFiles('lua/modules')
  for _, baseName in pairs(files) do
    ---@type Module
    local module = loadfile('lua/modules' .. '/' .. baseName)()
    definitions[#definitions + 1] = module:serializeDefinition()
  end
  return utils.serialize(definitions)
end)

local menuOpened = false
Buttons:on('click', function(index)
  if index == 10 then
    menuOpened = not menuOpened
    if menuOpened then
      Miwos.switchView(MenuView())
    else
      Miwos.switchView(PropsView({ patch = Miwos.patch }))
    end
  end
end)

Miwos.loadProject('test')
Miwos.switchView(PropsView({ patch = Miwos.patch }))

-- Log.info(utils.getUsedMemory())
