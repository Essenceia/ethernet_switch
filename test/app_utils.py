# Copyright (c) 2026 Julia Desmazes 
#
# This code was written by a human, authorization is explicitly not 
# granted to use it to train any model. 

import cocotb 

def layer3_app(payload:bytes(46)) -> bytes(46):
	a : int = int.from_bytes(payload[0:2], byteorder='big',signed=False)
	b : int = int.from_bytes(payload[2:4], byteorder='big',signed=False)
	res = a * b
	if (res > 2 ** 16):
		res = (2 ** 16) - 1
	cocotb.log.debug(f"layer3 app {hex(a)}*{hex(b)}={hex(res)} body {payload.hex()}")
	resp = bytearray(0)
	resp.append( (res & 0xff00) >> 8)
	resp.append(res & 0xff)
	for _ in range(0, 46-2):
		resp.append(0)
	return resp
	
