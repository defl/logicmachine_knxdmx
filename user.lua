--
-- Place this code in a User script
--

local luadmx = require('luadmx')
module('DMX', package.seeall)


local knxdmx_defaults = {
}

 
--
-- KNXDMX class
--
 
local KnxDmx = {}


--
-- Constructor
--
function KnxDmx:new(params)
  
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
 
  -- Find maximum number of channels
  local dmx_channel_id_max = 0
  for _, dmx_channel_ids in pairs(params.knx_dmx_mapping) do
    for _, dmx_channel_id in ipairs(dmx_channel_ids) do
      if dmx_channel_id > dmx_channel_id_max then
        dmx_channel_id_max = dmx_channel_id
      end
    end
  end
  log(string.format("DMX:new(): Highest DMX channel id %s", dmx_channel_id_max))
  
  -- Open and configure luaDMX 
  self.luadmx, err = luadmx.open(self.params.dmx_port)
  if err then
    os.sleep(1)
    error(err)
  end
  log("DMX:new(): luaDMX opened port successfully")
 
  self.luadmx:setcount(dmx_channel_id_max)
  self.luadmx:setall(0)
  self.luadmx:send()

  -- Rebuild dmx channel map structure to zero
  self.dmx_channels = {}
  for _, dmx_channel_ids in pairs(params.knx_dmx_mapping) do
    for _, dmx_channel_id in ipairs(dmx_channel_ids) do   
      self.dmx_channels[ dmx_channel_id ] = { current=0, target=0, ticks=0, delta=0 }
    end
  end

  -- Sleep
  self.transition_sleep = 1.0 / self.params.transition_update_hz
  log(string.format("DMX:new(): When transitioning sleeping %s sec/iteration", self.transition_sleep))

  -- Connect to redis and clean out queue
  _, self.redis = pcall(require('redis').connect) 
  self.redis:ltrim("knxdmx", 1, 0)
    
  return o
end


--
-- Loop is called in the resident script at interval 0
--
function KnxDmx:loop()

  -- Get update
  -- TODO: drain all updates
  local has_update = false
  local data = self.redis:lpop("knxdmx_updates")
  if data ~= nil then

    --log(string.format("KnxDmx:loop(): %s", data))
    
    local s = string.split(data, "_")
    local knx_address = s[1]
    local knx_value = tonumber(s[2]) or 0
    
    --log(string.format("KnxDmx:loop(): KNX %s to %s", knx_address, knx_value))
    

    local dmx_channel_ids = self.params.knx_dmx_mapping[knx_address]
    if dmx_channel_ids ~= nil then
      for i, dmx_channel_id in ipairs(dmx_channel_ids) do
      
        -- 0-100% to 0-254 (TODO: note that garden light dimmers don't like 255 so can't use round()?!?!?)
        local dmx_value_to = math.floor(knx_value * 2.55)

        local dmx_value_from = self.dmx_channels[dmx_channel_id].target

        log(string.format("KnxDmx:loop(): DMX %s to %s->%s", dmx_channel_id, dmx_value_from, dmx_value_to))
        
        -- we brighten fast
        if dmx_value_to > dmx_value_from then

        	self.dmx_channels[dmx_channel_id].target = dmx_value_to
        	self.dmx_channels[dmx_channel_id].delta = (self.dmx_channels[dmx_channel_id].target - self.dmx_channels[dmx_channel_id].current)
        	self.dmx_channels[dmx_channel_id].ticks = 1    

        -- dim slowly
        elseif dmx_value_to < dmx_value_from then

        	self.dmx_channels[dmx_channel_id].target = dmx_value_to
        	self.dmx_channels[dmx_channel_id].delta = (self.dmx_channels[dmx_channel_id].target - self.dmx_channels[dmx_channel_id].current) / 20
        	self.dmx_channels[dmx_channel_id].ticks = 20
        end        
        
      end
    end
    
    has_update = true
  end

  -- Update all channels
  local is_transitioning = false
  for dmx_channel_id, data in pairs(self.dmx_channels) do

    -- Transition
    if data.ticks > 0 then
         
      data.ticks = data.ticks - 1
      data.current = data.target - data.delta * data.ticks
      log(string.format("KnxDmx:loop(): dmx=%s tick=%s current=%s delta=%s target=%s", dmx_channel_id, data.ticks, data.current, data.delta, data.target))
      
      self.luadmx:setchannel(dmx_channel_id, data.current)

      is_transitioning = true  -- Not true for last one, but don't care
    end
	end
    
  self.luadmx:send()
  
  -- If we are transitioning, sleep shortly else sleep for more human time
  if is_transitioning then
    os.sleep(self.transition_sleep)
  else
    os.sleep(0.2)
  end
end


--
-- Set the KNX lighting value
-- This is a static or class function, cannot use self here
--
function KnxDmx:set_knx(knx_channel, value)

  -- TODO: Should be able to use table 
  local data = string.format("%s_%s", knx_channel, value)
  log(string.format("KnxDmx:set_knx(): %s to %s: %s", knx_channel, value, data))
  
  -- Storage is a redis store under the hood, push an update
  storage.exec('rpush', "knxdmx_updates", data)
end


return KnxDmx
