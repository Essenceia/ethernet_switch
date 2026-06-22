# 100Mbps Ethernet Switch ASIC

Fully open source 3 port cut-through unmanaged 100Mbps ethernet switch ASIC targetting the Global Foundary 180nm MCU node. 

![feature](/docs/feature.png) 

This unmanaged switch is equiped with a small internal mac address table to keep track of which devices
are connected downstream of each of it's ports. During operations it will autonomously update this internal 
table based on the source mac addresses of incomming packets. When packets addresses to a know entry 
are received they are routed only to the port associated with this entry. If a packet is targetting an 
unknown destination mac address or a broadcast address the packet is broadcasted on all ports appart 
from the port it is comming from. 

## Improvements 

List of potenciel future improvements :
- 10Mbps support with dynamic switching between 100Mbps and 10Mbps
- Add perf counters and expose said counters over JTAG 
- Add analog content addressable memory for address table

## Credits

Thanks to the Tiny Tapeout project, its contributors, and all the community working on open source silicon tools for making this possible.

## License 

This hardware is distributed under the **strongly** reciprocal CERN Open Hardware Licence Version 2 unless
otherwise specified.

### Tiny Tapeout exception

Any submission of this design, or derivatives thereof, made through the Tiny Tapeout 
shuttle program is additionally licensed under the Apache License 2.0 and is exempt from the 
reciprocal requirements of CERN-OHL-S-2.0 solely for that purpose.
