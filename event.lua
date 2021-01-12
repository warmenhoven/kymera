EVENT = EVENT or {}

function EVENT.fireEvent(strEvent)
   print("Firing event: " .. strEvent)
   C4:FireEvent(strEvent)
end

function EVENT.fireEventByID(nEvent)
   print("Firing event by id: " .. nEvent)
   C4:FireEventByID(nEvent)
end

EVENT.isDiscovered = false

function EVENT.discovered(status)
   if (EVENT.isDiscovered ~= status) then
      EVENT.fireEvent(status and "Discovered" or "Offline")
   end
   EVENT.isDiscovered = status
end
