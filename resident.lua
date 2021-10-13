--
-- Place this code in an Resident script
--
-- Resident scripts will call their code every given interval
-- and will preserve state in between calls.
--

-- run only once and only once
if not kd then

  -- Must be name of the user script you create
  KnxDmx = require('user.knxdmx')
  
  -- Config
  kd = KnxDmx:new({
    dmx_port = '/dev/RS485-1',    -- RS-485 port to use (RS-485 to DMX mapping: A=+, B=-)
    knx_dmx_mapping = {
      ["15/0/7"]  = {1},    -- Controls DMX channel 1
      ["15/0/12"] = {2,3},  -- Controls DMX channels 2 and 3

  }})
end
 
-- Loops once through
kd:loop()
