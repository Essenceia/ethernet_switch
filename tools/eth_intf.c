#include "eth_intf.h"

int get_eth_intf_info(int socket, const char *eth_intf, uint8_t eth_mac[6]){
	struct ifreq req;
	strncpy(req.ifr_name, eth_intf, IFNAMSIZ);
	
	if(ioctl(socket, SIOCGIFHWADDR, &req) < 0){
		perror("ioctl SIOCGIFHWADDR");
		return EXIT_FAILURE;
	}
	memcpy(eth_mac, req.ifr_hwaddr.sa_data, sizeof(eth_mac));
	return 0;	
}

