import System.IO
import Chaos

class Test(IHarness):
	Length as int
	
	def constructor():
		Length = 0
		Chaos(self)
	
	def Run(chaos as Chaos, iter as int, instance as int):
		fn = 'Temp\\test{0}.bin' % (instance, )
		fp = File.Open(fn, FileMode.Create)
		for i in range(Length):
			fp.WriteByte(0x42)
		fp.WriteByte(0x41)
		fp.Close()
		hit = chaos.Start('Harnesses\\Test\\Fuzztest.exe', fn)
		if hit != null:
			hit.AddFile(fn)
			hit.Send()
		Length += 1

Test()
