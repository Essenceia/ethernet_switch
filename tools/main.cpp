#include <linux/if_ether.h>
#define ETH_P_802_EX2	0x88B6 // second experimental ethtype missing from linux headers

#include "packets.hpp"

#include <iostream>

using namespace std;

int main(int argc, char * argv[]){
	int socket; 
	uint8_t eth_mac[6];
	char *eth_intf_name; 

	if (argc != 3){
		cout << "Usage: " + string(argv[0]) + " <eth_intf> <asic_mac_addr>" << endl;
		exit(EXIT_FAILURE);
	}

	/* open raw socket */
	int socket = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_802_EX1));
	if (socket < 0 ){
		perror("Failed to create raw socket");
		return EXIT_FAILURE;
	}
	/* resolve device mac addr */
	if (get_eth_intf_info(socket, eth_intf_name, eth_mac) < 0) 
		return EXIT_FAILURE;

	

}
