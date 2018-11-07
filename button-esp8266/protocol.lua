
local module = {}

ECHO = string.byte('E')
BLINK = string.byte('B')
SINGLE_TAP = string.byte('R')
RANDOM_TAPS = string.byte('M')
STOP = string.byte('S')

ws = websocket.createClient()

function pr(text)
  return function()
    print(text)
  end
end

function module.init(opt, cb)
  options = opt or {}
  callbacks = cb or {}
  server = options.server or "ws://192.168.0.12:8080/websocket"
  onEcho = callbacks.onEcho or pr("onEcho")
  onStop = callbacks.onStop or pr("onStop")
  onSingleTap = callbacks.onEcho or pr("onSingleTap")
  onRandomTaps = callbacks.onRandomTaps or pr("onRandomTaps")

  ws:on("receive", function(_, data, opcode)
    cmd = string.byte(data, 1)
    payload = string.sub(data, 2)
    
    if cmd == ECHO then
      onEcho(payload)
    elseif cmd == STOP then
      onStop(payload)
    elseif cmd == BLINK then
      onSingleTap(payload)
    elseif cmd == SINGLE_TAP then
      onSingleTap(payload)
    elseif cmd == RANDOM_TAPS then
      onRandomTaps(payload)
    --else
    --  print("Command not recognized:" .. cmd)
    end
  end)

  ws:connect(server)
end

function module.send(msg)
  ws:send(msg)
end

return module

