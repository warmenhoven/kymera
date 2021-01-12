require("kymera")
require("mdns")
require("timer")

discoveryTimerTime = 10000

DISCOVERY = DISCOVERY or {}

function DISCOVERY.init()
   DISCOVERY.startTimer()
end

function DISCOVERY.startTimer()
   TIMER.set("discovery",
             discoveryTimerTime,
             function() DISCOVERY.discover() end,
             false)
end

function DISCOVERY.discover()
   local serviceName = "_kymera._tcp.local"
   print("Starting MDNS query of " .. serviceName)
   local res = mdns_query(serviceName)
   if (res) then
      for k,v in pairs(res) do
         print("MDNS: " .. k)
         for k1,v1 in pairs(v) do
            print("MDNS: " .. "  " .. k1 .. ": " .. v1)
         end
         KYMERA.setDiscovered(v)
      end
   else
      print("No MDNS result")
      KYMERA.setDiscovered(nil)
      DISCOVERY.startTimer()
   end
end
