require('Log')
require('Timer')
require('Hmr')
require('Testing')
require('Bridge')
require('Miwos')

Miwos.createPatch()
Miwos.createModule('Input')
Miwos.createModule('Output')

Bridge.addMethod('/patch/addModuleInstance', function(...)
  return Miwos.patch:addModuleInstance(...)
end)
