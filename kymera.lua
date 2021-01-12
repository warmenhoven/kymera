require("event")

WebSocket = require("websocket")

KYMERA = KYMERA or {}

function KYMERA.init()
   KYMERA.setDiscovered(false)
end

function KYMERA.setDiscovered(tDevice)
   if (tDevice) then
      if (KYMERA.ip ~= tDevice["ipv4"]) then
         KYMERA.ip = tDevice["ipv4"]
         print("Kymera discovered at " .. KYMERA.ip)
         EVENT.discovered(true)
         KYMERA.connect()
      end
   else
      KYMERA.ip = nil
      EVENT.discovered(false)
      KYMERA.disconnect()
   end
   C4:UpdateProperty("IP Address", KYMERA.ip or "")
end

function KYMERA.connect()
   if (KYMERA.ws) then
      KYMERA.disconnect()
   end

   KYMERA.ws = WebSocket:new("ws://" .. KYMERA.ip .. "/")

   local pm = function(self, data)
      KYMERA.processMessage(data)
   end
   KYMERA.ws:SetProcessMessageFunction(pm)

   local est = function(self)
      print("ws connection established")
   end
   KYMERA.ws:SetEstablishedFunction(est)

   local closed = function(self)
      print("ws connection closed by remote host")
      KYMERA.connect()
   end
   KYMERA.ws:SetClosedByRemoteFunction(closed)

   KYMERA.ws:Start()
end

function KYMERA.processMessage(data)
   print("Received: " .. data)
   local id = tonumber(data)
   if (id >= 1 and id <= 13) then
      EVENT.fireEventByID(id)
   end
end

function KYMERA.disconnect()
   if (KYMERA.ws) then
      KYMERA.ws:Close()
      KYMERA.ws:delete()
      KYMERA.ws = nil
   end
end
