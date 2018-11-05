
local module = {}

function defaultListener ()
  print("defaultListener")
end

onPushListener = defaultListener

function module.setPushListener (onPush)
  onPushListener = onPush
end

function debounce (func)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function _onPush ()
  onPushListener()
end

gpio.mode(2, gpio.INT, gpio.PULLUP)
gpio.trig(2, "both", debounce(_onPush))

return module

