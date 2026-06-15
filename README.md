# Teapot Project

100Mbps Ethernet wrapper for hardware accelerators. 

![overview](/docs/overview.svg)

This project creates an ethernet interface for a generic hardware accelerator applications and handles 
ethernet frame streamin and out of input and output data. 

## Ethernet packets

This wrapper workes with layer 2 ethernet packets, opperating at the level of the ethernet frame. It support two 
types of packets: 
- `application packets` whos payload is passed to the accelerator
- `configuration packets` used to set the ASICs MAC address, Vlan IDentifier, and the TX phase selection

All packets whos destination MAC do not match the ASIC's current MAC address will be filtered out.
Unless otherwise specified the ASIC's MAC address is `00:90:CF:00:BE:EF` (read as Nortel:BEEF).
 
### Application packets

The application packet payload is streamed to the accelerator though the application wrapper. 
In the case of this design, the accelerator is a custom bfloat16 multiplier, so the payload will 
contain the two 16 bit values `A` and `B` we wish to multiply. 

**Request**
```
[ dst mac (6 Bytes) ][ src mac (6 Bytes) ][ ethtype = 0x88B5 (2 Bytes) ][ A (2 Bytes) ][ B (2 Bytes) ][ padding (42 Bytes) ][ FCS (4 Bytes) ] 
0
```

The result of the accelerator's computation, here `C=A*B`, will be contained in the payload of the response packet addressed to the
`src mac` of the original request packet. 

**Response**
```
[ dst mac (6 Bytes) ][ src mac (6 Bytes) ][ ethtype = 0x88B5 (2 Bytes) ][ C (2 Bytes) ][ padding (44 Bytes) ][ FCS (4 Bytes) ] 
0
```

Response packet streamout will start as soon as the last bits of `B` are received, for area reasons, the ASIC will not 
check for corrupted FCS or if the ethernet frame length complies with the 802.3 spec. 

Unless otherwise configured application packets use ethertype `0x88B5`, the first IEEE 802.3 specified "Local Experimental Ethertype".

### Configuration packets

Configuration packets are used to set the ASIC's current: 
- MAC address
- Vlan ID
- TX data to clock phase offset

These packets are not forwarded to the accelerator, do not provide any acknoledgement and due to our area limitation 
are not store and forwarded. Any corrupted packets will result in a corrupted configuration. 

**Packet**:
```
[ dst mac (6 Bytes) ][ src mac (6 Bytes) ][ ethtype = 0x88B6 (2 Bytes) ][ New MAC (6 Bytes) ][ padding (3 bits)][ VID (12 bits)][ padding (38 Bytes) ][ FCS (4 Bytes) ]
0
```

Unless otherwise configured application packets use ethertype `0x88B6`, the second IEEE 802.3 specified "Local Experimental Ethertype", 
whos existence linux networking libraries are unaware of. So trust me: it's real. 

#### Configuration parameters 

##### MAC address

ASIC's current MAC address, all packets not addressed (`dst mac`) to this address will be filtered out, 
and all responses will use this as the source address. 

Default MAC: `00:90:CF:00:BE:EF` (read as Nortel:BEEF)

##### VLAN ID
In the event a packet is vlan tagged, packets not matching the VLAN ID will be filtered out. 
If a packet isn't vlan tagged, it is assumed to belong to our current VLAN. 

Default VLAN ID: `0xDAD`

## Configuration pins

##### TX data to reference clock phase offset
To comphensate for the output data to reference clock offset induced by the delay on the path from the clock 
input pin, to the tiny tapeout design's data out flip-flop and back to the output pin, the reference 
clock for the data out flip flop is selectable, allowing us to use a 180 degree dephased reference clock. 

This dephasing configuration is captured during reset depending on the state of the `tx_phase` pin. 

Values: 
- `0` no phase shift
- `1` 180 degree phase shift

## Assumptions 

Desgin will be using the [official microchip LAN8720A daughter board](https://www.microchip.com/en-us/development-tool/AC320004-3#Overview) for testing.

This ASIC will be supporting 100Mbps ethernet using the following assumptions: 
- PHY will be implemented used the microchip LAN8720A(I) chips
- External network is full duplex 
		- dropping CRS support in asic 
- No 10Mbps support
	- dissabling auto-negociation
- LAN8720A clk is provided by an external clocks that is shared with the ASIC.
- Stream from LAN8720A is assumed gapeless, any packet gaps will trigger the ongoing packet to be tagged as containing an error

## MAC behavior 

This MAC supports: 
- jumbo frames upto 9000 bytes 
- VLAN tagging (802.21Q) 

The MAC will filter out all unicast packets not matching the configured
destination MAC address. This implies that all broadcast and multicast 
packets will be forwarded. 

## Improvements 

List of potenciel future improvements :
- 10Mbps support with dynamic switching between 100Mbps and 10Mbps
- Adding VLAN tagging to responses from VLAN tagged packets 
- Make the wrapper easy to import into a third party project
- Add perf counters and expose said counters over JTAG 
- Management data to JTAG bridge ? (MDIO/MDC)

## Credits

Thanks to the Tiny Tapeout project, its contributors, and all the community working on open source silicon tools for making this possible.
