#include "eth_intf.h"
#include <string.h> 
#include <sys/ioctl.h>
#include <net/if.h>
#include <stdio.h> 

int get_eth_intf_info(int socket, const char *eth_intf, uint8_t eth_mac[6]){
	struct ifreq req;
	strncpy(req.ifr_name, eth_intf, IFNAMSIZ);
	
	if(ioctl(socket, SIOCGIFHWADDR, &req) < 0){
		return -1;
	}
	memcpy(eth_mac, req.ifr_hwaddr.sa_data, 6);
	return 0;	
}

void print_mac(const uint8_t mac[6]){
	printf("%02x:%02x:%02x:%02x:%02x:%02x\n",mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}
