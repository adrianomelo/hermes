
local led = {}

BRIGHTNESS = 1

function led.init()
  ws2812.init()
  ledBuffer = ws2812.newBuffer(12, 3)
  ws2812_effects.init(ledBuffer)
end

function led.turnOff()
  ws2812_effects.set_mode("blink")
  ws2812_effects.set_color(0,0,0)
  ws2812_effects.set_brightness(0)
end

function led.turnOn()
  blink()
end

function led.wait()
  rainbowCycle()
end

function rainbowCycle()
  ws2812_effects.stop()
  ws2812_effects.set_brightness(BRIGHTNESS)
  ws2812_effects.set_speed(240)
  ws2812_effects.set_mode("rainbow_cycle")
  ws2812_effects.start()
end


function rainbow()
  ws2812_effects.stop()
  ws2812_effects.set_brightness(BRIGHTNESS)
  ws2812_effects.set_speed(255)
  ws2812_effects.set_mode("rainbow")
  ws2812_effects.start()
end

function blink()
  ws2812_effects.stop()
  ws2812_effects.set_brightness(BRIGHTNESS)
  ws2812_effects.set_speed(240)
  ws2812_effects.set_mode("blink")
  ws2812_effects.set_color(255,0,0)
  ws2812_effects.start()
end

return led

