
local module = {}


function module.now()
  sec, usec, rate = rtctime.get()
  return sec * 1000000 + usec
end

function module.diffToNow(time)
  timeNow = module.now()
  return timeNow - time
end

return module

