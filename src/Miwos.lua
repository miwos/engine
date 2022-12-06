local class = require('class')
local Module = require('Module')
local Patch = require('Patch')

---@class Miwos
---@field patch Patch | nil
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
