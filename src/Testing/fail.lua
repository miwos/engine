local utils = require('utils')

local function printFailDefault(assertion, received, expected)
  Testing.print(
    string.format(
      '{gray {italic expect(}}{error received}{gray {italic ):%s(}}{success expected}{gray {italic )}} \n',
      assertion
    )
  )

  if received == expected then
    Testing.print(
      string.format('{gray expected {underline not}} {success %s} \n', expected)
    )
  else
    Testing.print(string.format('{gray received: {error %s}} \n', received))
    Testing.print(string.format('{gray expected: {success %s}} \n', expected))
  end
end

local function printFailCompact(assertion, received, expected)
  Testing.print(
    string.format(
      '{gray {italic expect(}}{error %s}{gray {italic ):%s(}}{success %s}{gray {italic )}} ',
      received,
      assertion,
      expected
    )
  )
end

local function fail(assertion, text, received, ...)
  local files, suites, tests = Testing._files, Testing._suites, Testing._tests
  local currentFile, currentSuite, currentTest =
    Testing._currentFile, Testing._currentSuite, Testing._currentTest

  if not currentFile.hasFailed then
    currentFile.hasFailed = true
    files.failed = files.failed + 1

    local colorized = string.gsub(
      currentFile.name,
      '(.*/)(.*)(-test.lua)',
      '{error ×} {error %1}%2{error %3} \n'
    )
    print(colorized)
  end

  if not currentSuite.hasFailed then
    currentSuite.hasFailed = true
    suites.failed = suites.failed + 1

    Testing.print(string.format('{error • %s} ', currentSuite.name), -2)
  end

  if not currentTest.hasFailed then
    currentTest.hasFailed = true
    tests.failed = tests.failed + 1

    Testing.print(string.format('{error > %s} ', currentTest.name), -1)
  end

  local receivedSerialized = Testing.serialize(received)
  -- There can be multiple expected values, for example when using
  -- `toBeCalledWith(1, 2, 3)`.
  local expectedSerialized = utils.maskCurlyBraces(
    utils.serialize({ ... }, true):sub(3, -3)
  )

  if text then
    printFailCompact(assertion, receivedSerialized, expectedSerialized)
    Testing.print('{gray ' .. text .. '} ')
  elseif receivedSerialized:len() + expectedSerialized:len() <= 120 then
    printFailCompact(assertion, receivedSerialized, expectedSerialized)
  else
    printFailDefault(assertion, receivedSerialized, expectedSerialized)
  end
  print()
end

return fail
