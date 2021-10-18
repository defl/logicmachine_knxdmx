--
-- Place this code in a User script
--

local luadmx = require('luadmx')
module('DMX', package.seeall)


local knxdmx_defaults = {
  update_hz            = 10.0,  -- Amount of loops per second, more than 15 doesn't work less than 5 is ugly
  up_transition_time   =  0.2,  -- Transition time for increased light output in seconds, fast on is often welcome
  down_transition_time =  2.0,  -- Transition time for decreased light output in seconds, longer is nicer
}

local STORAGE_KEY = 'knxdmx'


--
-- KNXDMX class
--
 
local KnxDmx = {}


--
-- Constructor
--
function KnxDmx:new(params)
  
  log(string.format("DMX:new(): Rebuilding KNX-DMX light state..."))
  
  o = {}
  setmetatable(o, self)
  self.__index = self
 
   -- Set params, merging in defaults where needed
  self.params = params or {}
  for k, v in pairs(knxdmx_defaults) do
    if self.params[ k ] == nil then
      self.params[ k ] = v
    end
  end
 
  -- Process DMX-KNX config, build lookup maps, check for dupes
  self.knx_on_off_map = {}
  self.knx_brightness_map = {}
  self.dmx_channels = {}
  self.transitioning_channels = {}
  local dmx_channel_id_max = 0
  for _, data in pairs(params.knx_dmx_mapping) do
    
      -- Check for dupe config errors
      if self.knx_on_off_map[data.knx_on_off] ~= nil then
        error(string.format("DMX:new(): knx_on_off address %s already defined earlier in knx_on_off", data.knx_on_off))
      end
      if self.knx_brightness_map[data.knx_on_off] ~= nil then
        error(string.format("DMX:new(): knx_on_off address %s already defined earlier in knx_brightness", data.knx_on_off))
      end
      if self.knx_on_off_map[data.knx_brightness] ~= nil then
        error(string.format("DMX:new(): knx_brightness address %s already defined earlier in knx_on_off", data.knx_brightness))
      end
      if self.knx_brightness_map[data.knx_brightness] ~= nil then
        error(string.format("DMX:new(): knx_brightness address %s already defined earlier in knx_brightness", data.knx_brightness))
      end

      -- DMX find max channel and init channel data
      for _, dmx_channel_id in ipairs(data.dmx) do
        dmx_channel_id_max = math.max(dmx_channel_id, dmx_channel_id_max)
        self.dmx_channels[ dmx_channel_id ] = { current=0, target=0, ticks=0, delta=0 }
      end
    
      -- Store this record in lookups for on_off and brightness
      self.knx_on_off_map[data.knx_on_off] = data
      self.knx_brightness_map[data.knx_brightness] = data
    
      -- Write KNX state to all off (force)
      grp.write(data.knx_on_off, false)
      grp.write(data.knx_brightness, 0)
  end
  log(string.format("DMX:new(): Reset all KNX state, highest DMX channel id %s, %s DMX channels", dmx_channel_id_max, #self.dmx_channels))
  
  -- Open and configure luaDMX 
  self.luadmx, err = luadmx.open(self.params.dmx_port)
  if err then
    os.sleep(1)
    error(err)
  end
  log(string.format("DMX:new(): luaDMX opened port \"%s\" successfully", self.params.dmx_port))
 
  self.luadmx:setcount(dmx_channel_id_max+3)  -- This is needed because of bug in underlying DMX lib, else it won't steer higher addresses
  self.luadmx:setall(0)
  self.luadmx:send()

  -- Sleep
  self.sleep_time = 1.0 / self.params.update_hz
  log(string.format("DMX:new(): Sleep time %ss", self.sleep_time))

  -- Ticks
  self.up_transition_ticks   = math.max(1, math.floor(self.params.up_transition_time * self.params.update_hz))
  self.down_transition_ticks = math.max(1, math.floor(self.params.down_transition_time * self.params.update_hz))
  log(string.format("DMX:new(): Ticks up %s, down %s", self.up_transition_ticks, self.down_transition_ticks))
  
  -- Connect to redis and clean out queue. 
  -- This is similar to the storage API but with a persistant connection for performance
  _, self.redis = pcall(require('redis').connect) 
  self.redis:ltrim(STORAGE_KEY, 1, 0)
  log(string.format("DMX:new(): Ready to light up your life! (storage key \"%s\")", STORAGE_KEY))

  return o
end


--
-- Loop is called in the resident script at interval 0
--
function KnxDmx:loop()

  -- Get single update per loop
  while true do
    local data = self.redis:lpop(STORAGE_KEY)
    if data ~= nil then

      -- Decode the knx address and number
      local s = string.split(data, "_")
      local knx_group_address = s[1]
      local knx_value = tonumber(s[2]) or 0

      -- Find as brightness
      local data = self.knx_brightness_map[knx_group_address]
      if data ~= nil then
        
        -- Update DMX
        local dmx_value_to = math.floor((knx_value * 2.55) + 0.5) -- 0-100% to 0-255
        if dmx_value_to < 0 or dmx_value_to > 255 then
          error(string.format("KnxDmx:loop(): dmx=%s attempt to update to invalid value %s", dmx_channel_id, dmx_value_to))
        end
        
        self:dmx_update_channels(data.dmx, dmx_value_to)
        
        -- TODO: We can push this to a queue, only to be processed on idle. Not sure if that's slower.
        if dmx_value_to > 0 then
          grp.checkwrite(data.knx_on_off, true)
        else
          grp.checkwrite(data.knx_on_off, false)
        end
      end

      -- TODO: Respond to on/off as well?
      
    -- No more data, stop waiting for it
    else
      break
    end
    
    -- You can put a small wait here for more set_knx() data points to arrive, this will make the first
    -- action to take longer (~second in total for 5 channels) but it will feel smoother as all move at the
    -- same time. I prefer my lights to be on faster and hence I don't do this.
    -- os.wait(0.2)    
  end

  -- Update transitioning channels
  for dmx_channel_id, data in pairs(self.transitioning_channels) do
    
    data.ticks = data.ticks - 1
    data.current = data.target - data.delta * data.ticks
    
    --log(string.format("KnxDmx:loop(): dmx=%s tick=%s current=%s delta=%s target=%s", dmx_channel_id, data.ticks, data.current, data.delta, data.target))
      
    self.luadmx:setchannel(dmx_channel_id, data.current)
    
    -- When done auto-remove ourselves (this is safe), else mark as transitioning
    if data.ticks == 0 then
      self.transitioning_channels[dmx_channel_id] = nil
      --log(string.format("KnxDmx:loop(): DMX %s update done", dmx_channel_id))
    end
  end
  
  -- Send DMX
  self.luadmx:send()
  
  os.sleep(self.sleep_time)
end

  
--
-- Loop is called in the resident script at interval 0
--
-- @param dmx_channel_ids: Table of channel ids as number
-- @param dmx_value_to: DMX target value [0-255]
--
function KnxDmx:dmx_update_channels(dmx_channel_ids, dmx_value_to)
    
  for i, dmx_channel_id in ipairs(dmx_channel_ids) do

    local data = self.dmx_channels[dmx_channel_id]

    local dmx_value_from = data.target
    --log(string.format("KnxDmx:dmx_update_channels(): DMX %s requested move %s->%s", dmx_channel_id, dmx_value_from, dmx_value_to))

    -- Up/down differ
    local ticks = 0
    if dmx_value_to > dmx_value_from then
      ticks = self.up_transition_ticks

    elseif dmx_value_to < dmx_value_from then
      ticks = self.down_transition_ticks
    end

    -- Do we need to do anything?
    if ticks > 0 then

      --log(string.format("KnxDmx:dmx_update_channels(): DMX %s updating %s->%s in %s ticks", dmx_channel_id, dmx_value_from, dmx_value_to, ticks))

      -- Update channel
      data.target = dmx_value_to
      data.delta = (data.target - data.current) / ticks
      data.ticks = ticks

      -- Add to transitioning channels
      self.transitioning_channels[dmx_channel_id] = data
    end
  end
end  


--
-- Set the KNX lighting value
-- This is a static or class function, cannot use self here
--
-- @param knx_group_address: KNX group address as string (ex. "1/2/3")
-- @param value: Value to set to, depends on type, expected is 0-100 for brightness
--
function KnxDmx:set_knx(knx_group_address, value)

  -- TODO: Should be able to use table but could not get it to work
  local data = string.format("%s_%s", knx_group_address, value)
  
  -- Storage is a redis store under the hood, push an update
  storage.exec('rpush', STORAGE_KEY, data)
end


return KnxDmx
