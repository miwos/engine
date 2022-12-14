return {
  modules = {
    { id = 1, type = 'Input', props = { device = 4, cable = 1 } },
    { id = 2, type = 'Output', props = { device = 1, cable = 1 } },
  },
  connections = {
    { 1, 1, 2, 1 },
  },
  mappings = {
    {
      { 1, 'device' },
    },
    {
      { 2, 'device' },
    },
  },
}
