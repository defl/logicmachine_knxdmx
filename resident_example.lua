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
      {knx_on_off="1/0/0",  knx_brightness="1/0/2",  dmx={26}},  -- B.1
      {knx_on_off="1/0/5",  knx_brightness="1/0/7",  dmx={92}},  -- B.2 CW
      {knx_on_off="1/0/10", knx_brightness="1/0/12", dmx={93}},  -- B.2 WW

      {knx_on_off="2/0/0",  knx_brightness="2/0/2",  dmx={112}},  -- E.1 CW
      {knx_on_off="2/0/5",  knx_brightness="2/0/7",  dmx={113}},  -- E.1 WW
      {knx_on_off="2/0/10", knx_brightness="2/0/12", dmx={96}},   -- E.2 CW
      {knx_on_off="2/0/15", knx_brightness="2/0/17", dmx={97}},   -- E.2 WW
    
      {knx_on_off="3/0/0",  knx_brightness="3/0/2",  dmx={86}},  -- G.1
      {knx_on_off="3/0/5",  knx_brightness="3/0/7",  dmx={87}},  -- G.2

      {knx_on_off="4/0/0",  knx_brightness="4/0/2",   dmx={98}},   -- H.1 CW
      {knx_on_off="4/0/5",  knx_brightness="4/0/7",   dmx={99}},   -- H.1 WW
      {knx_on_off="4/0/10", knx_brightness="4/0/12",  dmx={100}},  -- H.2 CW
      {knx_on_off="4/0/15", knx_brightness="4/0/17",  dmx={101}},  -- H.2 WW
      {knx_on_off="4/0/20", knx_brightness="4/0/22",  dmx={116}},  -- H.3 CW
      {knx_on_off="4/0/25", knx_brightness="4/0/27",  dmx={117}},  -- H.3 WW
      {knx_on_off="4/0/30", knx_brightness="4/0/32",  dmx={114}},  -- H.4 CW
      {knx_on_off="4/0/35", knx_brightness="4/0/37",  dmx={115}},  -- H.4 WW
      {knx_on_off="4/0/40", knx_brightness="4/0/42",  dmx={106}},  -- H.5 CW
      {knx_on_off="4/0/45", knx_brightness="4/0/47",  dmx={107}},  -- H.5 WW
      {knx_on_off="4/0/50", knx_brightness="4/0/52",  dmx={110}},  -- H.6 CW
      {knx_on_off="4/0/55", knx_brightness="4/0/57",  dmx={111}},  -- H.6 WW

      {knx_on_off="5/0/0",  knx_brightness="5/0/2",   dmx={104}},  -- K.1 CW
      {knx_on_off="5/0/5",  knx_brightness="5/0/7",   dmx={105}},  -- K.1 WW
      {knx_on_off="5/0/10", knx_brightness="5/0/12",  dmx={118}},  -- K.2 CW
      {knx_on_off="5/0/15", knx_brightness="5/0/17",  dmx={119}},  -- K.2 WW
      {knx_on_off="5/0/20", knx_brightness="5/0/22",  dmx={122}},  -- K3.CW
      {knx_on_off="5/0/25", knx_brightness="5/0/27",  dmx={123}},  -- K3.WW
      {knx_on_off="5/0/30", knx_brightness="5/0/32",  dmx={94}},   -- K.4 CW
      {knx_on_off="5/0/35", knx_brightness="5/0/37",  dmx={95}},   -- K.4 WW
      {knx_on_off="5/0/40", knx_brightness="5/0/42",  dmx={22}},   -- K.5

      {knx_on_off="6/0/0",  knx_brightness="6/0/2",  dmx={102}},  -- TB.1 CW
      {knx_on_off="6/0/5",  knx_brightness="6/0/7",  dmx={103}},  -- TB.1 WW

      {knx_on_off="7/0/0",  knx_brightness="7/0/2",  dmx={108}},  -- W.1 CW
      {knx_on_off="7/0/5",  knx_brightness="7/0/7",  dmx={109}},  -- W.1 WW

      {knx_on_off="8/0/0",  knx_brightness="8/0/2",   dmx={64, 65}},  -- T.1
      {knx_on_off="8/0/10", knx_brightness="8/0/12",  dmx={80}},      -- T.2
      {knx_on_off="8/0/15", knx_brightness="8/0/17",  dmx={81}},      -- T.3
      {knx_on_off="8/0/20", knx_brightness="8/0/22",  dmx={28}},      -- T.4
      {knx_on_off="8/0/25", knx_brightness="8/0/27",  dmx={29}},      -- T.5
      {knx_on_off="8/0/30", knx_brightness="8/0/32",  dmx={66, 67, 69, 70, 71, 72, 73, 75}},  -- T.6
      {knx_on_off="8/0/35", knx_brightness="8/0/37",  dmx={68, 74, 77, 78}},                  -- T.7

      {knx_on_off="9/0/0",  knx_brightness="7/0/2",  dmx={82}},  -- TH.1
        
      {knx_on_off="11/0/0",  knx_brightness="11/0/2",   dmx={5}},   -- D.1 CW
      {knx_on_off="11/0/5",  knx_brightness="11/0/7",   dmx={6}},   -- D.1 WW
      {knx_on_off="11/0/10", knx_brightness="11/0/12",  dmx={9}},   -- D.2 CD
      {knx_on_off="11/0/15", knx_brightness="11/0/17",  dmx={10}},  -- D.2 WW
      {knx_on_off="11/0/20", knx_brightness="11/0/22",  dmx={7}},   -- D.3 CW
      {knx_on_off="11/0/25", knx_brightness="11/0/27",  dmx={8}},   -- D.3 WW

      {knx_on_off="12/0/0",  knx_brightness="12/0/2",   dmx={90}},  -- O.1 CW
      {knx_on_off="12/0/5",  knx_brightness="12/0/7",   dmx={91}},  -- O.1 WW
      {knx_on_off="12/0/10", knx_brightness="12/0/12",  dmx={32, 33, 34, 35, 36, 37, 38, 39}},   -- O.2
      {knx_on_off="12/0/15", knx_brightness="12/0/17",  dmx={61}},  -- O.3

      {knx_on_off="13/0/0",  knx_brightness="13/0/2",   dmx={58}},   -- S1.2 CW
      {knx_on_off="13/0/5",  knx_brightness="13/0/7",   dmx={59}},   -- S1.2 WW
      {knx_on_off="13/0/10", knx_brightness="13/0/12",  dmx={120}},  -- S1.4 CW
      {knx_on_off="13/0/15", knx_brightness="13/0/17",  dmx={121}},  -- S1.4 WW

      {knx_on_off="14/0/0",  knx_brightness="14/0/2",   dmx={20}},  -- S4.1
      {knx_on_off="14/0/5",  knx_brightness="14/0/7",   dmx={21}},  -- S4.3
        
      {knx_on_off="15/0/0",  knx_brightness="15/0/2",   dmx={24}},  -- S2.1
      {knx_on_off="15/0/5",  knx_brightness="15/0/7",   dmx={1}},   -- S2.3 CW
      {knx_on_off="15/0/10", knx_brightness="15/0/12",  dmx={2}},   -- S2.3 WW
        
      {knx_on_off="16/0/0",  knx_brightness="16/0/2",   dmx={3}},  -- TV.1 CW
      {knx_on_off="16/0/5",  knx_brightness="16/0/7",   dmx={4}},  -- TV.1 WW
        
      {knx_on_off="21/0/0",  knx_brightness="16/0/2",   dmx={60}},  -- F.1

      {knx_on_off="22/0/0",  knx_brightness="22/0/2",   dmx={40, 41, 42}},  -- Z.1
      {knx_on_off="22/0/5",  knx_brightness="22/0/7",   dmx={50}},          -- Z.2 CW
      {knx_on_off="22/0/10", knx_brightness="22/0/12",  dmx={51}},          -- Z.2 WW
        
      {knx_on_off="23/0/0",  knx_brightness="23/0/2",   dmx={56}},  -- S.1 CW
      {knx_on_off="23/0/5",  knx_brightness="23/0/7",   dmx={57}},  -- S.1 WW
      {knx_on_off="23/0/10", knx_brightness="23/0/12",  dmx={52}},  -- S.2 CW
      {knx_on_off="23/0/15", knx_brightness="23/0/17",  dmx={53}},  -- S.2 WW
      {knx_on_off="23/0/20", knx_brightness="23/0/22",  dmx={54}},  -- S.3 CW
      {knx_on_off="23/0/25", knx_brightness="23/0/27",  dmx={55}},  -- S.3 WW
  }})
end
 
kd:loop()
