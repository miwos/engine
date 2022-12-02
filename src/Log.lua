local utils = require('utils')

Log = _G.Log or {}

---@enum LogType
local LogType = {
  Info = 1,
  Warn = 2,
  Error = 3,
  Dump = 4,
}

---@type fun(type: LogType, ...: any)
function Log.log(type, ...)
  local args = { ... }
  local message = ''
  for i = 1, select('#', ...) do
    message = message .. (i > 1 and ', ' or '') .. tostring(args[i])
  end
  Log._log(type, message)
end

function Log.error(...)
  Log.log(LogType.Error, ...)
end

function Log.warn(...)
  Log.log(LogType.Warn, ...)
end

function Log.info(...)
  Log.log(LogType.Info, ...)
end

function Log.dump(...)
  local args = { ... }
  local dump = ''

  for i = 1, select('#', ...) do
    local value = args[i]
    dump = dump .. (i > 1 and ', ' or '') .. utils.serialize(value)
  end

  Log._log(LogType.Dump, dump)
end

local timers = {}

---@type fun(label: string)
function Log.time(label)
  timers[label] = Timer.now()
end

---@type fun(label: string)
function Log.timeEnd(label)
  Log.info(label .. ': ' .. Timer.now() - timers[label] .. 'μs')
  timers[label] = nil
end
