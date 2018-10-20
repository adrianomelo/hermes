print "Starting..."
--tmr.delay(1000000)
print "...now!"

server = '192.168.0.11'

BRIGHTNESS = 1

rtctime.set(0)

function now()
  sec, usec, rate = rtctime.get()
  return sec * 1000000 + usec
end

function diffToNow(time)
  timeNow = now()
  return timeNow - time
end

ws2812.init()
ledBuffer = ws2812.newBuffer(12, 3)
ws2812_effects.init(ledBuffer)

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

function turnOff()
  ws2812_effects.set_color(0,0,0)
  ws2812_effects.set_brightness(0)
end

function turnOn()
  blink()
end

on = false
onTime = 0
function _stop()
  if (on == true) then
    turnOff()
    on = false
  end
end

function _start()
  if (on == false) then
    turnOn()
    onTime = now()
    on = true
  end
end

function createConfigService()
  return {
    ipAddr = "192.168.0.11",
    pingUrl = "http://192.168.0.11:8080/ping",
    wsUrl = "ws://192.168.0.11:8080/websocket"
  }
end

configService = createConfigService()

function testHttp(configService)
  http.get(configService.pingUrl, nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
  end)
end

ECHO = string.byte('E')
BLINK = string.byte('B')
REACT = string.byte('R')

function startWS()
 ws = websocket.createClient()
 ws:on("receive", function(_, data, opcode)
    cmd = string.byte(data, 1)
    payload = string.sub(data, 2)
    
    if cmd == ECHO then
      ws:send("e"..payload)
    elseif cmd == REACT then
      _start()
    end
 end)
 ws:connect(configService.wsUrl)
end

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("IP:", T.IP, "mask: ", T.netmask, "GW:", T.gateway)
 startWS()
end)

wifi.sta.config{ssid="?", pwd="?"}
wifi.sta.connect()

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

function onPush()
  if (on == true) then
    reaction = diffToNow(onTime)
    ws:send('b' .. reaction)
  end
  _stop()
end

gpio.mode(2, gpio.INT, gpio.PULLUP)
gpio.trig(2, "both", debounce(onPush))

