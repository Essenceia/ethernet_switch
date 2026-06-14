<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

ASIC ethernet accelerator wrapper. 

## How it works

TODO
 
## How to test

Connect the ethernet 100Mbps capable connector to the asic, if the connector doesn't 
expose a `rx_err` signal clamp it to gnd. 
Cable the ethernet connector to your local network, it doesn't have to be directly 
to your computer so long your are in the same local network (layer2 packets can be routed
within it). 

Build the packet sender/receiver app in `tools`: 
```
cd tools
make
```

To run pass the name of your ethernet interface currently connected to the same 
LAN as the ASIC. Eg: I am connected though my wifi interface: 
```
sudo ./packet_sender wlp3s0
```
You can also observe the packets being sent back by sniffing your live traffic
via tcpdump: 
```
sudo tcpdump -xx -e -v 'ether proto 0x88b5'
```

The ASIC will only respond to application packet (ethtype:`0x88b5`) requests sent to it, a packet must me sent 
first to initiate a response. 

## External hardware

Ethernet 100BASE-T Pmod connector, featuring: 
- LAN8720A PHY 
- 50MHz oscillator

