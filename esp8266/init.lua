print "Starting..."
tmr.delay(1000000)
print "...now!"

server = '192.168.0.11'

function createConfigService()
  return {
    ipAddr = "192.168.0.11",
    pingUrl = "http://192.168.0.11:8080/ping",
    wsUrl = "ws://192.168.0.11:8080/ws"
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

function startWS()
 ws = websocket.createClient()
 ws:on("connection", function(ws)
   print('got ws connection')
   ws:send("hello")
 end)
 ws:on("receive", function(_, msg, opcode)
   print('got message:', msg, opcode) -- opcode is 1 for text message, 2 for binary
 end)
 ws:on("close", function(_, status)
   print('connection closed', status)
   ws = nil -- required to Lua gc the websocket client
   startWS()
 end)
 ws:connect(configService.wsUrl)
end

function listap(t)
      for ssid,v in pairs(t) do
        authmode, rssi, bssid, channel = 
          string.match(v, "(%d),(-?%d+),(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x),(%d+)")
        print(ssid,authmode,rssi,bssid,channel)
      end
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\tChannel: "..T.channel)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
 T.BSSID.."\n\treason: "..T.reason)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
 print("\n\tSTA - AUTHMODE CHANGE".."\n\told_auth_mode: "..
 T.old_auth_mode.."\n\tnew_auth_mode: "..T.new_auth_mode)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
 T.netmask.."\n\tGateway IP: "..T.gateway)
 testHttp(configService)
 startWS()
 end)

 wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
 print("\n\tSTA - DHCP TIMEOUT")
 end)

 wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
 print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
 end)

 wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
 print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
 end)

 wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T)
 print("\n\tAP - PROBE REQUEST RECEIVED".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
 end)

 wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
 print("\n\tSTA - WIFI MODE CHANGED".."\n\told_mode: "..
 T.old_mode.."\n\tnew_mode: "..T.new_mode)
 end)


--wifi.setmode(wifi.STATION)
--wifi.sta.getap(listap)
--wifi.sta.config{ssid="?", pwd="?"}
--wifi.sta.connect()

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
  ws:send('{"event": "BUTTON"}')
end

gpio.mode(2, gpio.INT, gpio.PULLUP)
gpio.trig(2, "both", debounce(onPush))

--dofile("hcsr04.lua")
--device = hcsr04.init()
--tmr.alarm(0, 1000, 1, function() print(device.measure_avg()) end)

