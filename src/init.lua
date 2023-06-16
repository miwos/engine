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
local Utils = require('Utils')

require('modules.Input')
require('modules.Output')
require('modules.Chord')
require('modules.Delay')
require('modules.Strings')
require('modules.ChordSplit')

require('modulators.Lfo')

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
    local cachedModule = _LOADED['modules.' .. baseName]
    local module = cachedModule or loadfile('lua/modules' .. '/' .. baseName)()
    definitions[#definitions + 1] = module:serializeDefinition()
  end
  return Utils.serialize(definitions)
end)

Bridge.addMethod('/e/modules/definition', function(name)
  local cachedModule = _LOADED['modules.' .. name]
  local module = cachedModule or loadfile('lua/modules' .. '/' .. name)()
  return Utils.serialize(module:serializeDefinition())
end)

Bridge.addMethod('/e/modules/prop', function(moduleId, name, value)
  Miwos.patch:updatePropValue(moduleId, name, value)
  Miwos:emit('prop:change', moduleId, name, value)
end)

Bridge.addMethod('/e/patch/clear', function()
  Miwos.patch:clear()
  Miwos:emit('patch:change')
end)

Bridge.addMethod('/e/mappings/add', function(page, slot, id, prop)
  Miwos.patch:addMapping(page, slot, id, prop)
  Miwos:emit('patch:change')
end)

Bridge.addMethod('/e/mappings/remove', function(page, slot)
  Miwos.patch:removeMapping(page, slot)
  Miwos:emit('patch:change')
end)

Bridge.addMethod('/e/project/load', function(name)
  Miwos.loadProject(name, false)
  Miwos.switchView(PropsView({ patch = Miwos.patch }))
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

Miwos.loadSettings()
Miwos.loadProject('test')
Miwos.switchView(PropsView({ patch = Miwos.patch }))

Midi.start()

-- Log.info(Utils.getUsedMemory())
