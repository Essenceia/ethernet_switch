#include "eth_intf.h"
#include <string.h> 
#include <sys/ioctl.h>
#include <net/if.h>
#include <stdio.h> 

int get_eth_intf_info(int socket, const char* eth_intf, int* eth_intf_idx, mac_addr_t eth_mac){
	struct ifreq req;
	strncpy(req.ifr_name, eth_intf, IFNAMSIZ);
	
	if(ioctl(socket, SIOCGIFHWADDR, &req) < 0){
		return -1;
	}
	memcpy((uint8_t*)eth_mac, req.ifr_hwaddr.sa_data, 6);

	if(ioctl(socket, SIOCGIFINDEX, &req) < 0){
		return -1;
	}
	*eth_intf_idx = req.ifr_ifindex;
	return 0;	
}

void print_mac(const mac_addr_t mac_addr){
	uint8_t* mac = (uint8_t*)mac_addr;
	printf("%02x:%02x:%02x:%02x:%02x:%02x\n",mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}

int parse_mac(const char *mac_str, uint8_t mac[6]) {
    int parsed = sscanf(mac_str, "%02x:%02x:%02x:%02x:%02x:%02x",
                        &mac[0], &mac[1], &mac[2],
                        &mac[3], &mac[4], &mac[5]);
    if (parsed != 6) return -1;
    return 0;
}
