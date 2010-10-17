import struct, sys

class DecompPict(object):
	def __init__(self, fn):
		self.fp = file(fn, 'rb')
		
		self.fp.seek(0x200, 0)
		self.header()
		
		while True:
			opcd = self.short
			
			method = 'opcode_%04X' % opcd
			if not hasattr(self, method):
				print 'Unknown opcode %04X' % opcd
				break
			getattr(self, method)()
	
	@property
	def short(self):
		return struct.unpack('>H', self.fp.read(2))[0]
	
	@property
	def long(self):
		return struct.unpack('>L', self.fp.read(4))[0]
	
	def header(self):
		print 'File size: %04X' % self.short
		print 'Frame top-left: %04X %04X' % (self.short, self.short)
		print 'Frame bottom-right: %04X %04X' % (self.short, self.short)
		
		magic = self.short
		if magic == 0x1101:
			print 'v1.0 file'
			self.header10()
		elif magic == 0x0011:
			if self.short == 0x02FF:
				self.header20()
			else:
				print 'v2.0 magic but not number'
		else:
			print 'Other'
	
	def header20(self):
		opcode = self.short
		if opcode != 0x0C00:
			print 'Bad header opcode: %04X' % opcode
		
		print 'Static: %04X' % self.short
		print 'Reserved: %04X == 0000?' % self.short
		print 'Original resolution: %i x %i' % (self.long, self.long)
		print 'Frame top-left: %04X %04X' % (self.short, self.short)
		print 'Frame bottom-right: %04X %04X' % (self.short, self.short)
		print 'Reserved: %08X == 00000000?' % self.long
	
	def opcode_0001(self):
		print 'Clip: %04X %04X %04X %04X %04X' % (self.short, self.short, self.short, self.short, self.short)
	
	def opcode_001E(self):
		print 'DefHilite'
	
	def opcode_8200(self):
		size = self.long
		print 'Compressed quicktime: length == %08X' % size
		print size

if __name__=='__main__':
	DecompPict(*sys.argv[1:])
