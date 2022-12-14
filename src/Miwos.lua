local class = require('class')
local Module = require('Module')
local Patch = require('Patch')
local EventEmitter = require('EventEmitter')
local Component = require('Component')
local mixin = require('mixin')

---@class Miwos : EventEmitter
---@field patch Patch | nil
---@field view Component | nil
Miwos = _G.Miwos or {}
mixin(Miwos, EventEmitter)
Miwos.__events = {}
Miwos.moduleDefinitions = {}

---@alias Signal 'midi' | 'trigger'
---@class ModuleOptions
---@field inputs Signal[]
---@field outputs Signal[]

---@type fun(name: string, options: ModuleOptions): Module
function Miwos.defineModule(name, definition)
  local module = class(Module) --[[@as Module]]
  module.__type = name
  module.__events = {}
  module.__definition = definition
  Miwos.moduleDefinitions[name] = module
  return module
end

function Miwos.defineProp(name, component)
  Prop.list[name] = component
end

---@type fun(type: string): Component
function Miwos.defineComponent(type)
  local component = class(Component) --[[@as Component]]
  component.__type = type
  component.__events = {}
  return component
end

---@type fun(view: Component)
function Miwos.switchView(view)
  local prevView = Miwos.view
  if prevView then prevView:__unmount() end
  view:__mount()
  Miwos.view = view
end

function Miwos.loadProject(name)
  local data = loadfile('lua/projects/' .. name .. '/part-1.lua')()
  Miwos.patch = Patch()
  Miwos.patch:deserialize(data)
  Miwos:emit('patch:change', Miwos.patch)
end
