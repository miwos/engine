require('Log')
require('Timer')
require('Hmr')
require('Bridge')
require('Miwos')
require('Midi')
require('Encoders')
require('Buttons')

local PropsView = require('ui.views.PropsView')

Miwos.createPatch()
Miwos.defineModule('Input')
Miwos.defineModule('Output')

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

Miwos.switchView(PropsView())
