---@class EncoderProps
---@field index ?number

---@class Encoder : Component
---@field props EncoderProps
local Encoder = Miwos.defineComponent('Encoder')

function Encoder:setup()
  self.index = self.props.index or self.ctx.slot or 1

  self.changeHandler = Encoders:on('change', function(index, value)
    if index == self.index then self:emit('change', value) end
  end)

  self.clickHandler = Encoders:on('click', function(index)
    if index == self.index then self:emit('click') end
  end)
end

function Encoder:write(value)
  Encoders.write(self.index, value)
end

function Encoder:setRange(min, max)
  Encoders.setRange(self.index, min, max)
end

function Encoder:unmount()
  Encoders:off('change', self.changeHandler)
  Encoders:off('click', self.clickHandler)
end

return Encoder
