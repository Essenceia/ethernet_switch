#include <linux/if_ether.h>
#define ETH_P_802_EX2	0x88B6 // second experimental ethtype missing from linux headers

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <stdint.h> 
#include <arpa/inet.h>

#include <sys/ioctl.h>
#include <net/if.h> 
#include <string.h> 

#include "eth_intf.h"


int main(int argc, char * argv[]){
	int sock; 
	uint8_t eth_mac[6];
	char eth_intf_name[IFNAMSIZ] = {0}; 

	if (argc < 2 && argc > 3){
		printf("Usage: %s eth_intf [asic_mac_addr]\nGot %d(%d) arguments\n", argv[0],argc - 1, argc);
		return -1;
	}
	printf("ethernet interface: %s\n", argv[1]);
	if (strlen(argv[1]) > IFNAMSIZ -1){
		printf("Missformed ethernet interface argument: %s", argv[1]);
	}
	strncpy(eth_intf_name, argv[1], IFNAMSIZ); 

	/* open raw socket */
	sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_802_EX1));
	if (sock < 0 ){
		printf("Socket creation failed, do you have the sufficent permissions ?\n");
		return -1;
	}
	/* resolve device mac addr */
	if (get_eth_intf_info(sock, eth_intf_name, eth_mac) < 0){ 
		printf("interface questing failed\n");
		return -1;
	}

	printf("%s mac address :", eth_intf_name);
	print_mac(eth_mac);

	

}
