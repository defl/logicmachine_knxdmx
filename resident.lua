--
-- Place this code in an Resident script
--
-- Resident scripts will call their code every given interval
-- and will preserve state in between calls.
--

-- run once and only once
if not kd then

  -- Must be name of the user script you create
  KnxDmx = require('user.knxdmx')
  
  -- Config
  kd = KnxDmx:new({
    dmx_port = '/dev/RS485-1',    -- RS-485 port to use (RS-485 to DMX mapping: A=+, B=-)
    transition_update_hz = 10.0,  -- Amount of updates per second, keep as low as not visible
    up_transition_time = 0.5,     -- Transition time for increased light output in seconds, fast on is often welcome
    down_transition_time = 1.0,   -- Transition time for decreased light output in seconds, longer is nicer
    knx_dmx_mapping = {
      ["15/0/7"]  = {1},  -- S2.3 CW
      ["15/0/12"] = {2},  -- S2.3 WW
      ["16/0/2"]  = {3},  -- TV.1 CW
      ["16/0/7"]  = {4},  -- TV.1 WW
      ["11/0/2"]  = {5},  -- D.1 CW
      ["11/0/7"]  = {6},  -- D.1 WW
      ["11/0/22"] = {7},  -- D.3 CW
      ["11/0/27"] = {8},  -- D.3 WW
      ["11/0/12"] = {9},  -- D.2 CD
      ["11/0/17"] = {10},  -- D.2 WW
      ["14/0/2"]  = {20},  -- S4.1
      ["14/0/7"]  = {21},  -- S4.3
      ["5/0/42"]  = {22},  -- K.5
      ["15/0/2"]  = {24},  -- S2.1
      ["1/0/2"]   = {26},  -- B.1
      ["8/0/22"]  = {28},  -- T.4
      ["8/0/27"]  = {29},  -- T.5
      ["12/0/12"] = {32, 33, 34, 35, 36, 37, 38, 39},  -- O.2
      ["22/0/2"]  = {40, 41, 42},  -- Z.1
      ["22/0/7"]  = {50},  -- Z.2 CW
      ["22/0/12"] = {51},  -- Z.2 WW
      ["23/0/12"] = {52},  -- S.2 CW
      ["23/0/17"] = {53},  -- S.2 WW
      ["23/0/22"] = {54},  -- S.3 CW
      ["23/0/27"] = {55},  -- S.3 WW
      ["23/0/2"]  = {56},  -- S.1 CW
      ["23/0/7"]  = {57},  -- S.1 WW
      ["13/0/7"]  = {58},  -- S1.2 CW
      ["13/0/12"] = {59},  -- S1.2 WW
      ["21/0/2"]  = {60},  -- F.1
      ["12/0/17"] = {61},  -- O.3
      ["8/0/2"]   = {64, 65},  -- T.1
      ["8/0/32"]  = {66, 67, 69, 70, 71, 72, 73, 75},  -- T.6
      ["8/0/37"]  = {68, 74, 77, 78},  -- T.7
      ["8/0/2"]   = {76},	
      ["8/0/12"]  = {80},  -- T.2
      ["8/0/17"]  = {81},  -- T.3
      ["9/0/2"]   = {82},  -- TH.1
      ["3/0/2"]   = {86},  -- G.1
      ["3/0/7"]   = {87},  -- G.2
      ["12/0/2"]  = {90},  -- O.1 CW
      ["12/0/7"]  = {91},  -- O.1 WW
      ["1/0/7"]   = {92},  -- B.2 CW
      ["1/0/12"]  = {93},  -- B.2 WW
      ["5/0/32"]  = {94},  -- K.4 CW
      ["5/0/37"]  = {95},  -- K.4 WW
      ["2/0/12"]  = {96},  -- E.2 CW
      ["2/0/17"]  = {97},  -- E.2 WW
      ["4/0/2"]   = {98},  -- H.1 CW
      ["4/0/7"]   = {99},  -- H.1 WW
      ["4/0/12"]  = {100},  -- H.2 CW
      ["4/0/17"]  = {101},  -- H.2 WW
      ["6/0/2"]   = {102},  -- TB.1 CW
      ["6/0/7"]   = {103},  -- TB.1 WW
      ["5/0/2"]   = {104},  -- K.1 CW
      ["5/0/7"]   = {105},  -- K.1 WW
      ["4/0/42"]  = {106},  -- H.5 CW
      ["4/0/47"]  = {107},  -- H.5 WW
      ["7/0/2"]   = {108},  -- W.1 CW
      ["7/0/7"]   = {109},  -- W.1 WW
      ["4/0/52"]  = {110},  -- H.6 CW
      ["4/0/57"]  = {111},  -- H.6 WW
      ["2/0/2"]   = {112},  -- E.1 CW
      ["2/0/7"]   = {113},  -- E.1 WW
      ["4/0/32"]  = {114},  -- H.4 CW
      ["4/0/37"]  = {115},  -- H.4 WW
      ["4/0/22"]  = {116},  -- H.3 CW
      ["4/0/27"]  = {117},  -- H.3 WW
      ["5/0/12"]  = {118},  -- K.2 CW
      ["5/0/17"]  = {119},  -- K.2 WW
      ["13/0/17"] = {120},  -- S1.4 CW
      ["13/0/22"] = {121},  -- S1.4 WW
      ["5/5/11"]  = {122},  -- K3 PSU  -- TODO: This should not go smoothly but in 1 go
      ["5/0/22"]  = {125},  -- K3.CW
      ["5/0/27"]  = {126}   -- K3.WW
  }})
end
 
kd:loop()
