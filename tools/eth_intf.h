#ifndef ETH_INTF_H
#define ETH_INTF_H

#include <stdint.h>
#include "eth_defs.h" 

/* get eth interface mac 
socket (int), raw socket, returned from socket 
return error */
int get_eth_intf_info(int socket, const char *eth_intf, int* eth_intf_idx, mac_addr_t eth_mac); 

void print_mac(const mac_addr_t mac);
int parse_mac(const char *mac_str, uint8_t mac[6]);

#endif //ETH_INTF_H
