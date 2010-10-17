import System
import System.IO
import Chaos

class QTMinimize(IHarness):
	Fn as string
	
	def constructor(fn as string):
		Fn = fn
		Chaos(self, true)
	
	def Run(chaos as Chaos, i as int, instance as int):
		root = Fn.Split(char('\\'))
		rootfn = root[root.Length-1]
		split = Fn.Split(char('.'))
		extension = split[split.Length-1]
		initfp = File.OpenRead(Fn)
		init = array [of byte](initfp.Length)
		initfp.Read(init, 0, initfp.Length)
		initfp.Close()
		
		lastfn as string = null
		def test(base as int, top as int, nodelete as bool):
			lastfn = fn = 'Temp\\{0}.{1}.{2}.{3}' % (rootfn, base, top, extension)
			fp = File.OpenWrite(fn)
			fp.Write(init, 0, top)
			fp.Close()
			
			hit = chaos.Start(true, 'Harnesses\\Quicktime\\QTTest.exe', fn)
			
			if not nodelete:
				try:
					File.Delete(fn)
				except:
					print 'Couldn\'t delete {0}' % (fn, )
			
			return hit
		
		print 'Minimizing...'
		oval = val = init.Length
		shift = 0
		while val != 0:
			shift += 1
			val >>= 1
		if 2 ** (shift-1) == oval:
			shift -= 1
		
		base, top = 0, init.Length
		run = 0
		while top-base > 1:
			run += 1
			print base, top, '{0}/{1}' % (run, shift)
			if test(base, base + (top - base) / 2, false) != null:
				top = base + (top - base) / 2
			else:
				base = base + ((top - base) / 2)
		
		hit = test(base, top, true)
		hit.AddFile(lastfn)
		hit.Send()
		print 'Minimal size: {0}/{1}' % (top, init.Length)

QTMinimize(argv[0])
