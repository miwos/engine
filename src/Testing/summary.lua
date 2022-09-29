local function printSummarySection(name, total, failed)
  local parts = {}

  if failed > 0 then
    parts[#parts + 1] = string.format('{error failed %s}', failed)
  end

  local passed = total - failed
  if passed then
    parts[#parts + 1] = string.format('{success passed %s}', passed)
  end

  print(
    string.format(
      '%s %s {gray of %s} ',
      name,
      table.concat(parts, '{gray ,} '),
      total
    )
  )
end

local function getSummary()
  print()
  printSummarySection('Files: ', Testing._files.total, Testing._files.failed)
  printSummarySection('Suites:', Testing._suites.total, Testing._suites.failed)
  printSummarySection('Tests: ', Testing._tests.total, Testing._tests.failed)
  return Testing._tests.failed == 0
end

return getSummary
