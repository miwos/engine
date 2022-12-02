Timer = _G.Timer or {}
Timer.Sec = 1000000
Timer.Milli = 1000
local events = {}

---@type fun(now: number)
function Timer.update(now)
  local finishedCallbacks = {}

  for callback, time in pairs(events) do
    if time <= now then
      events[callback] = nil
      finishedCallbacks[#finishedCallbacks + 1] = callback
    end
  end

  for _, callback in ipairs(finishedCallbacks) do
    callback()
  end
end

---@type fun(callback: function, time: number): function
function Timer.schedule(callback, time)
  events[callback] = time
  return callback
end

---@type fun(callback: function, delay: number): function
function Timer.delay(callback, delay)
  events[callback] = Timer.now() + delay
  return callback
end
