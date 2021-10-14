# LogicMachine KNX-DMX gateway

This is a set of scripts to be used with an [EmbeddedSystems LogicMachine](https://openrb.com/) to turn it into a 
nicer DMX gateway. 

LogicMachines are widely used in KNX installations when you need more complexity than what the usually simple 
KNX logic blocks of devices can provide; they offer Blocks/Lua scripting and IO options which can be combined
to build things such as KNX-DMX gateways.

EmbeddedSytems provides a sample DMX gateway implementation in their manuals and [online](https://openrb.com/example-dmx-lighting-control-with-lm2/) but that has various problems such as:

- It has a delay of up to a second which makes it feel unresponsive
- Requires KNX addressing to match DMX addressing
- It does not support assymetric on/off timings
- It's hard to read and uses undocumented non-public API trickery

Because I was in need of a DMX gateway that worked, and I use a LM5 Lite already which I'm happy with in terms of stability, 
I decided to improve upon the DMX scripts to make them suit my needs better and the provided scripts. 

Pro:
- It's faster than the script in the manual
- Flexible config of 1 KNX group to multiple DMX channels

Con:
- LogicMachine takes time to process and send the DMX packets, you'll not get as nice transitions as you can with a dedicated device

## Installation
In the LogicMachine GUI website go to "LogicMachine" -> "Scripting" and add a script in the following classes:
 - Event-based -> Add new script 
   - I named it "KnxDmx" but it does not matter, and add a tag, I use DMX. 
   - Do not execute on group read. 
   - Save.
   - Click editor icon for script and copy code from "event.lua" into editor. 
   - Save.
 - Resident -> Add new script 
   - I named it "KnxDmx" but it does not matter. Set Sleep Interval (seconds) to 0.
   - Save
   - Click editor icon for script and copy code from "resident.lua" into editor.
   - Edit config at the top. Generally not much to do.
   - Save
 - User libraries -> Add new script
   - Naming is important, call it "knxdmx" else you need to change the imports in the other scripts.
   - Keep source must be enabled.
   - Save
   - Click editor icon for script and copy code from "user.lua" into editor. 
   - Save.

Now go to your objects and tag every KNX group that needs to trigger a DMX channel with the tag you picked (DMX).

Done, let there be light.

## TODO
- Uses a hardcoded storage key "knxdmx_updates"
- Using string to transfer data pairs which I suspect takes more time than expected
- Not using wall-clock for transitions

## Background
At the time of writing most of the lights in my house are based off of DMX drivers (~128 channels in use).
There are multiple DMX lines which all come together centrally at a single DMX replicator unit. 
This unit is driven by a DMX master. 
All the buttons use KNX, hence I need to interface these two busses with a KNX-DMX gateway.
Because this is a critical system I would stronly prefer a dedicated gateway device.

I have used a Bab Technologie DUODMX gateway 12021 KNX for a year and found the following problems: 

- When many lights update at the same time, (>6 or so) the device intermittantly misses later KNX updates leading to not all lights turning on. 
- Can only be programmed with a dedicated Windows application over ethernet. The application is _quite_ poor in UI and keep-your-data terms which makes it a pain to work with.
- The firmware stops responding to programming requests from the UI after a little while requirding a hard reset of the device in order to program it again.  

At the time of writing there are no other cost-efficient ~128 channel gateways. I can start splitting up the DMX domain into
multiple smaller ones driven by smaller KNXDMX gateways such as the Weinzierl 544 (up to 64ch) but not looking forward
to debugging these.

## References
This is based on the published EmbeddedSystems code from https://openrb.com/example-dmx-lighting-control-with-lm2/
