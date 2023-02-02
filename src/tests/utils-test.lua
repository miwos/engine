local Utils = require('Utils')

describe('isArray', function()
  it('handles numbers', function()
    expect(Utils.isArray(99)):toBe(false)
  end)

  it('handles strings', function()
    expect(Utils.isArray('string')):toBe(false)
  end)

  it('handles tables', function()
    expect(Utils.isArray({ [2] = 2, [1] = 1 })):toBe(false)
  end)

  it('handles arrays', function()
    expect(Utils.isArray({ 1, 2, 3 })):toBe(true)
  end)
end)

describe('serialize', function() end)
