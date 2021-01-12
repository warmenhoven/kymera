require("discovery")
require("kymera")
require("timer")

do
   OCS = OCS or {}
   RFN = RFN or {}
end

function OnDriverInit()
   C4:AllowExecute(true)
end

function OnDriverLateInit()
   TIMER.killAll()
   KYMERA.init()
   DISCOVERY.init()
end

function OnDriverDestroyed()
   TIMER.killAll()
end

function OnConnectionStatusChanged (idBinding, nPort, strStatus)
   local output = {'--- OnConnectionStatusChanged: ' .. idBinding, nPort, strStatus}
   output = table.concat (output, '\r\n')
   print(output)

   local success, ret

   if (OCS and OCS [idBinding] and type (OCS [idBinding]) == 'function') then
      success, ret = pcall (OCS [idBinding], idBinding, nPort, strStatus)
   end

   if (success == true) then
      return (ret)
   elseif (success == false) then
      print ('OnConnectionStatusChanged Lua error: ', idBinding, nPort, strStatus, ret)
   end
end

function ReceivedFromNetwork (idBinding, nPort, strData)
   local output = {'--- ReceivedFromNetwork: ' .. idBinding, nPort, #strData}
   output = table.concat (output, '\r\n')
   print(output)

   local success, ret

   if (RFN and RFN [idBinding] and type (RFN [idBinding]) == 'function') then
      success, ret = pcall (RFN [idBinding], idBinding, nPort, strData)
   end

   if (success == true) then
      return (ret)
   elseif (success == false) then
      print ('ReceivedFromNetwork Lua error: ', idBinding, nPort, strData, ret)
   end
end
