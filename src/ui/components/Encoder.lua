---@class EncoderProps
---@field index ?number

---@class Encoder : Component
---@field props EncoderProps
local Encoder = Miwos.defineComponent()

function Encoder:setup()
  self.index = self.props.index or self.ctx.slot
  self.changeHandler = Encoders:on('change', function(index, value)
    if index == self.index then self:emit('change', value) end
  end)
end

function Encoder:write(value)
  Encoders.write(self.index, value)
end

function Encoder:setRange(min, max)
  Encoders.setRange(self.index, min, max)
end

function Encoder:unmount()
  Encoders:off(self.changeHandler)
end

return Encoder
