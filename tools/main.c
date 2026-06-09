#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <stdint.h> 
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <net/if.h> 
#include <string.h> 
#include <linux/if_packet.h> 
#include <net/if.h> 
#include <unistd.h> 

#include "eth_intf.h"
#include "packets.h" 

int main(int argc, char * argv[]){
	int sock; 
	int eth_intf_idx;
	char eth_intf_name[IFNAMSIZ] = {0};
	mac_addr_t device_mac_addr;
	mac_addr_t asic_mac_addr = DEFAULT_ASIC_MAC;

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
	sock = socket(AF_PACKET, SOCK_RAW, htons(APP_ETHTYPE));
	if (sock < 0 ){
		printf("Socket creation failed, do you have the sufficent permissions ?\n");
		return -1;
	}
	/* resolve device mac addr */
	if (get_eth_intf_info(sock, eth_intf_name, &eth_intf_idx, device_mac_addr) < 0){ 
		printf("interface questing failed\n");
		return -1;
	}

	printf("%s mac address ", eth_intf_name);
	print_mac(device_mac_addr);

	/* validate command line argument for asic dst mac */
	if (argc > 2){
		if(parse_mac(argv[2], (uint8_t*)asic_mac_addr) < 0){
			printf("malformed mac address argument, got %s", argv[2]);
		}
	}
	printf("asic mac address ");
	print_mac(asic_mac_addr);

	/* resolve dst address */
	struct sockaddr_ll sock_addr; 
	memset(&sock_addr, 0, sizeof(sock_addr));
	sock_addr.sll_family = AF_PACKET; 
	sock_addr.sll_protocol = htons(APP_ETHTYPE);
	sock_addr.sll_ifindex = eth_intf_idx;
	sock_addr.sll_pkttype = PACKET_OTHERHOST;
	sock_addr.sll_halen = MAC_W; 
	memcpy(sock_addr.sll_addr, asic_mac_addr, MAC_W);

	/* create application packet */
	uint8_t *raw_app_pkt = create_app_packet(asic_mac_addr, device_mac_addr, 0xBEEF,0xCAFE);

	/* send app packet */
    ssize_t sent;

	for (int i = 0; i < 500000; i++){
		if(sendto(sock, raw_app_pkt, APP_PACKET_LENGTH, 0,(struct sockaddr *)&sock_addr, sizeof(sock_addr)) < 0){
			//close(sock);
			free(raw_app_pkt);
			return -1;
		}
		if (i % 1000 == 0)printf("%04d message has sucesfully been sent\n", i);
		usleep(150);
	}

	//close(sock);
	free(raw_app_pkt); 
	return 0;
}
