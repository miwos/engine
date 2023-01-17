local ProgressBar = require('ui.components.ProgressBar')
local LabelValue = require('ui.components.LabelValue')
local Encoder = require('ui.components.Encoder')
local Display = require('ui.components.Display')
local utils = require('utils')

---@class NumberProps
---@field value number
---@field label string
---@field min number
---@field max number
---@field step number
---@field showScale boolean
---@field scaleUnit number
---@field scaleCount number

---@class Number : Component
---@field props NumberProps
local Number = Miwos.defineComponent('Number')

local function ease(x)
  return 1.383493
    + (0.00001915815 - 1.383493) / (1 + (x / 0.3963062) ^ 1.035488)
end

function Number:render()
  local props = self.props
  local scaleStep = 0

  if props.scaleCount then
    scaleStep = Display.width / props.scaleCount
  elseif props.scaleUnit then
    scaleStep = props.scaleUnit / (props.max - props.min) * Display.width
  else
    scaleStep = Display.width / (props.max - props.min)
  end

  return {
    encoder = Encoder(),
    progressBar = ProgressBar({
      x = 0,
      y = Display.height - 7,
      width = Display.width,
      height = 7,
      value = utils.mapValue(props.value, props.min, props.max, 0, 1),
      showScale = props.showScale,
      scaleStep = scaleStep,
    }),
    labelValue = LabelValue({
      x = 0,
      y = 0,
      width = Display.width,
      height = Display.height - 7,
      label = self.props.label,
    }),
  }
end

function Number:mount()
  local props = self.props
  self.encoderMax = math.floor(ease((props.max - props.min) / 127) * 127)

  local encoder = self.children.encoder --[=[@as Encoder]=]
  encoder:setRange(0, self.encoderMax)
  encoder:write(self:encodeValue(self.props.value))
end

Number:event('encoder:change', function(self, rawValue)
  local props = self.props

  local value = self:decodeValue(rawValue)
  self.children.labelValue:setProp('value', value)
  local normalizedValue = utils.mapValue(value, props.min, props.max, 0, 1)
  self.children.progressBar:setProp('value', normalizedValue)

  local oldValue = props.value
  props.value = value
  if value ~= oldValue then self:emit('updateValue', value) end
end)

Number:event('prop[value]:change', function(self, value)
  local props = self.props
  local encoder = self.children.encoder --[=[@as Encoder]=]
  encoder:write(self:encodeValue(props.value))

  self.children.progressBar:setProp(
    'value',
    utils.mapValue(props.value, props.min, props.max, 0, 1)
  )
end)

function Number:encodeValue(value)
  local props = self.props
  return utils.mapValue(value, props.min, props.max, 0, self.encoderMax)
end

function Number:decodeValue(rawValue)
  local props = self.props
  local scaledValue =
    utils.mapValue(rawValue, 0, self.encoderMax, props.min, props.max)

  return props.step and math.ceil(scaledValue / props.step) * props.step
    or scaledValue
end

return Number
