
local module = {}

function module.connect(onConnected)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("IP:", T.IP, "mask: ", T.netmask, "GW:", T.gateway)
    onConnected()
  end)

  wifi.setmode(wifi.STATION)
  wifi.sta.config{ssid="?", pwd=""}
  wifi.sta.connect()
end

return module

