#ifndef ETH_INTF_H
#define ETH_INTF_H

#include <stdint.h>

/* get eth interface mac 
socket (int), raw socket, returned from socket 
return error */
int get_eth_intf_info(int socket, const char *eth_intf, uint8_t eth_mac[6]); 

void print_mac(const uint8_t mac[6]);

#endif //ETH_INTF_H
