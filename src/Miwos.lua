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

---@type fun(name: string): Module
function Miwos.defineModule(name)
  local module = class(Module)
  module.__type = name
  module.__events = {}
  Miwos.moduleDefinitions[name] = Module
  return module
end
