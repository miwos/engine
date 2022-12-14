local ButtonsComponent = Miwos.defineComponent('Buttons')

function ButtonsComponent:mount()
  self.clickHanddler = Buttons:on('click', function(index)
    self:emit('click', index)
  end)
end

function ButtonsComponent:unmount()
  Buttons:off('click', self.clickHanddler)
end

return ButtonsComponent
