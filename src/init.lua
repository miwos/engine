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

require('modules.Input')
require('modules.Output')

local PropsView = require('ui.views.PropsView')

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

Miwos.loadProject('test')
Miwos.switchView(PropsView({ patch = Miwos.patch }))
