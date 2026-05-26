import crc_utils.py 


pkt = bytearray.fromhex("ffff00ff00ff0011223344000036d71484f8cf9bf4b76f47904730804b9e3225a9f133b5dea168f4e2851f072fcc00fcaa7ca62061717a48e52e29a3fa379a953faa6893")
print(f"pkt {pkt.hex()}")

crc = crc_utils.calc_fcs(pkt)
print(f"crc {crc.hex()}")

