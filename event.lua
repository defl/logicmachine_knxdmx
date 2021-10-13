--
-- Place this code in an Event-based script and tag
-- all relevant KNX lights with the same group tag
-- as you'll give the script.
--

-- Must be name of the user script you create
KnxDmx = require('user.knxdmx')

-- Catch config error
if event.type ~= 'groupwrite' then
  error("DMX script not designed for anything else than groupwrite")
end

-- Set value  
KnxDmx:set_knx(event.dst, event.getvalue())
