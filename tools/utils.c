/* Resolve the MAC address and interface index for a given interface name */
static int get_iface_info(int sock, const char *iface,
                          uint8_t mac_out[6], int *ifindex_out)
{
    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));
    strncpy(ifr.ifr_name, iface, IFNAMSIZ - 1);

    if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl SIOCGIFINDEX");
        return -1;
    }
    *ifindex_out = ifr.ifr_ifindex;

    if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0) {
        perror("ioctl SIOCGIFHWADDR");
        return -1;
    }
    memcpy(mac_out, ifr.ifr_hwaddr.sa_data, 6);
    return 0;
}

int main(void)
{
    /* Destination: broadcast — change to a specific MAC if needed */
    const uint8_t dst_mac[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    const char   *payload     = PAYLOAD;
    size_t        payload_len = strlen(payload);

    /* ------------------------------------------------------------------ */
    /* 1. Open a raw packet socket                                          */
    /* ------------------------------------------------------------------ */
    int sock = socket(AF_PACKET, SOCK_RAW, htons(CUSTOM_ETHERTYPE));
    if (sock < 0) {
        perror("socket");
        fprintf(stderr, "Did you run as root?\n");
        return EXIT_FAILURE;
    }

    /* ------------------------------------------------------------------ */
    /* 2. Resolve interface MAC + index                                     */
    /* ------------------------------------------------------------------ */
    uint8_t src_mac[6];
    int     ifindex;
    if (get_iface_info(sock, IFACE, src_mac, &ifindex) < 0) {
        close(sock);
        return EXIT_FAILURE;
    }

    printf("Interface : %s (index %d)\n", IFACE, ifindex);
    printf("Source MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
           src_mac[0], src_mac[1], src_mac[2],
           src_mac[3], src_mac[4], src_mac[5]);

