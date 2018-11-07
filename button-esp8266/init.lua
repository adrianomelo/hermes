print "Starting..."

led = dofile("led.lua")
wf = dofile("wf.lua")
button = dofile("button.lua")
time = dofile("time.lua")
protocol = dofile("protocol.lua")

rtctime.set(0)

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
    onTime = time.now()
    on = true
  end
end

function onEcho(payload)
  protocol.send("e" .. payload)
end

function onSingleTap(payload)
  _start()
end

function onConnected()
  protocol.init({}, {
    onEcho=onEcho,
    onSingleTap=onSingleTap
  })
end

function onPush()
  if (on == true) then
    reaction = time.diffToNow(onTime)
    protocol.send('b' .. reaction)
    _stop()
  end
end

led.init()
led.wait()

button.setPushListener(onPush)
wf.connect(onConnected)

