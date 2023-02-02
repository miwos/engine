local Utils = require('Utils')

Testing = {
  fn = require('Testing.mock'),
  expect = require('Testing.expect'),
  summary = require('Testing.summary'),
}

function Testing.reset()
  Testing._depth = 0
  Testing._files = { total = 0, failed = 0 }
  Testing._suites = { total = 0, failed = 0 }
  Testing._tests = { total = 0, failed = 0 }
end

---@type fun(n: number)
function Testing.depth(n)
  Testing._depth = Testing._depth + n
end

---@type fun(text: string, n?: number)
function Testing.print(text, n)
  n = n or 0
  print(Utils.indent(Testing._depth + n) .. text)
end

function Testing.serialize(...)
  local args = { ... }
  if #args == 1 then
    local value = args[1]
    if type(value) == 'table' and type(value.serialize) == 'function' then
      return Utils.maskCurlyBraces(value:serialize())
    else
      return Utils.maskCurlyBraces(Utils.serialize(value, true))
    end
  else
    local parts = {}
    for _, v in pairs(args) do
      parts[#parts + 1] = Testing.serialize(v)
    end
    return table.concat(parts, ', ')
  end
end

function Testing.runFile(fileName)
  Testing._currentFile = { name = fileName, hasFailed = false }
  Testing._files.total = Testing._files.total + 1

  loadfile(fileName)()

  if not Testing._currentFile.hasFailed then
    local colorized = string.gsub(
      fileName,
      '(.*/)(.*)(-test.lua)',
      '{success √} {gray %1}%2{gray %3} '
    )
    print(colorized)
  end

  return Testing._currentFile.hasFailed
end

---@type fun(dirName: string)
function Testing.runDir(dirName)
  Testing.reset()
  local files = FileSystem.listFiles(dirName)
  for _, baseName in pairs(files) do
    Testing.runFile(dirName .. '/' .. baseName)
  end
end

---@type fun(name: string, fn: function)
function Testing.describe(name, fn)
  Testing._currentSuite = { name = name, hasFailed = false }
  Testing._suites.total = Testing._suites.total + 1

  Testing.depth(1)
  fn()
  Testing.depth(-1)
end

---@type fun(name: string, fn: function)
function Testing.test(name, fn)
  Testing._currentTest = { name = name, hasFailed = false }
  Testing._tests.total = Testing._tests.total + 1

  Testing.depth(2)
  fn()
  Testing.depth(-2)
end

-- Init
Testing.reset()

describe = Testing.describe
expect = Testing.expect
test = Testing.test
it = Testing.test
