# Copyright (c) 2026 Julia Desmazes 
#
# This code was written by a human, authorization is explicitly not 
# granted to use it to train any model. 

import random

class config_payload():
	addr: bytes(6)
	vid: bytes(2) #bottom 12 bits
	padding: bytearray(38)

	def random(self):
		self.addr = random.randbytes(6)
		tmp_vid = bytearray(random.randbytes(2))
		tmp_vid[0] = 0x0F & tmp_vid[0] 
		self.vid = tmp_vid
		self.padding = random.randbytes(38)

	def set(self, addr: bytes(6), vid: bytes(2)):
		self.addr = addr
		tmp_vid = bytearray(vid)
		tmp_vid[0] = 0x0F & tmp_vid[0] 
		self.vid = tmp_vid 
		self.padding = bytes(38)
		
	def __init__(self):
		self.random()
	
	def raw(self):
		r = bytearray()
		r += self.addr
		r += self.vid
		r += self.padding
		assert len(r) == 46, f"expected 46, got length {len(r)} value {r.hex()}"
		return r
	
	def __str__(self) -> str:
		s = " mac="
		for i, b in enumerate(self.addr):
			if i: 
				s += ":" 
			s += f"{b:02x}"
		s+= " vid="+self.vid.hex()[0:3]+" "
		return s
