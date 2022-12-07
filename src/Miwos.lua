local class = require('class')
local Module = require('Module')
local Patch = require('Patch')
local EventEmitter = require('EventEmitter')
local Component = require('Component')

---@class Miwos
---@field patch Patch | nil
---@field view Component | nil
Miwos = _G.Miwos or {}

Miwos.moduleDefinitions = {}

function Miwos.loadPatch() end

function Miwos.createPatch()
  local patch = Patch()
  Miwos.patch = patch
  return Patch
end

---@alias Signal 'midi' | 'trigger'
---@class ModuleOptions
---@field inputs Signal[]
---@field outputs Signal[]

---@type fun(name: string, options: ModuleOptions): Module
function Miwos.defineModule(name, options)
  local module = class(Module) --[[@as Module]]
  module.__type = name
  module.__events = {}
  module.__options = options
  Miwos.moduleDefinitions[name] = Module
  return module
end

function Miwos.defineProp(name)
  local prop = class(EventEmitter)
  return prop
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
  if prevView then prevView:__destroy() end
  Miwos.view = view
end
