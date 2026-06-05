#ifndef PACKETS_H
#define PACKETS_H
#include <stdint.h>

struct eth_header_t{
	uint8_t dst_mac[6];
	uint8_t src_mac[6];
	uint16_t ethtype;
} __attribute__((packed));

struct app_packet_t{
	eth_header_t header;
	uint16_t a; // bf16
	uint16_t b; // bf16
	uint8_t padd[42];
} __attribute__((packed));

struct conf_packet_t{
	eth_header_t header;
	uint8_t mac_addr[6]; /* new mac address */
	uint16_t vid; /* bottom 12 bits */
	uint8_t phase; /* bottom 1 bit */
	uint8_t padd[38];
} __attribute__((packed));

#endif // PACKETS_H
