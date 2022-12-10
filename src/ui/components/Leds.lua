local LedsComponent = Miwos.defineComponent('Leds')

function LedsComponent:toggle(index, state)
  Leds.toggle(index, state)
end

return LedsComponent
