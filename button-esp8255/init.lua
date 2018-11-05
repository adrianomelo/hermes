print "Starting..."

led = dofile("led.lua")
wf = dofile("wf.lua")
button = dofile("button.lua")

rtctime.set(0)

function now()
  sec, usec, rate = rtctime.get()
  return sec * 1000000 + usec
end

function diffToNow(time)
  timeNow = now()
  return timeNow - time
end

on = false
onTime = 0
function _stop()
  if (on == true) then
    led.turnOff()
    on = false
  end
end

function _start()
  if (on == false) then
    led.turnOn()
    onTime = now()
    on = true
  end
end

function createConfigService()
  return {
    ipAddr = "192.168.0.12",
    pingUrl = "http://192.168.0.12:8080/ping",
    wsUrl = "ws://192.168.0.12:8080/websocket"
  }
end

configService = createConfigService()

ECHO = string.byte('E')
BLINK = string.byte('B')
REACT = string.byte('R')

function onConnected()
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

function onPush()
  if (on == true) then
    reaction = diffToNow(onTime)
    ws:send('b' .. reaction)
    _stop()
  end
end

led.init()
led.wait()

button.setPushListener(onPush)
wf.connect(onConnected)

