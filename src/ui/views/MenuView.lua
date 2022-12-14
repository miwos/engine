local List = require('ui.components.List')
local MenuView = Miwos.defineComponent('MenuView')

function MenuView:render()
  return {
    projects = List({ values = { 'test', 'test-2' } }, { slot = 1 }),
  }
end

MenuView:event('projects:select', function(self, value)
  Miwos.loadProject(value)
end)

return MenuView
