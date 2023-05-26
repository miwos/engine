return {
  modules = {
    {
      id = 1,
      type = 'Input',
      props = {
        device = 1,
        cable = 1,
      },
      position = {
        244,
        99,
      },
    },
    {
      id = 2,
      type = 'Output',
      props = {
        device = 1,
        cable = 1,
      },
      position = {
        468,
        465,
      },
    },
    {
      id = 3,
      type = 'Delay',
      props = {
        feed = 30,
        time = 100,
      },
      position = { 300, 300 },
    },
  },
  connections = {
    { 1, 1, 3, 1 },
    { 3, 1, 2, 1 },
  },
  modulators = {
    {
      id = 4,
      type = 'Lfo',
      props = { shape = 1, rate = 5 },
    },
    {
      id = 5,
      type = 'Lfo',
      props = { shape = 1, rate = 5 },
    },
  },
  modulations = {
    { 4, 3, 'time', 1 },
  },
  mappings = {
    [1] = {
      [1] = { 3, 'feed' },
      [2] = { 3, 'time' },
    },
  },
}
