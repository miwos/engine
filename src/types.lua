---@meta

---@alias Signal 'midi' | 'trigger'

---@class ModuleDefinition
---@field inputs Signal[]
---@field outputs Signal[]
---@field props table<string, Prop>
---@field shape string
---@field clipContent boolean
---@field label string
---@field module Module

---@class PropDefinition
---@field modulateValue fun(value: number, modulation: number, amount: number, options: table): number
---@field component Component

---@class ModulatorDefinition
---@field props table<string, Prop>
---@field modulator Modulator
