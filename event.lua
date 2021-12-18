--
-- Place this code in an Event-based script and tag
-- all relevant KNX lights with the same group tag
-- as you'll give the script.
--

-- Must be name of the user script you create
KnxDmx = require('user.knxdmx')

-- Set value
if event.type ~= 'groupwrite' then
  KnxDmx:set_knx(event.dst, event.getvalue())
end

-- Respond to getting value
if event.type == 'groupread' then
  obj = grp.find(event.dst)
  if obj and obj.decoded then  
    grp.response(event.dst, obj.value, obj.datatype)
  end
end
