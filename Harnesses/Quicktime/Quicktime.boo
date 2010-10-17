import System
import System.Collections.Generic
import System.IO
import System.Threading
import Chaos

class FileManipulator:
	Init as (byte)
	public Extension as string
	
	def constructor(init as string, extension as string):
		fp = File.OpenRead(init)
		Init = array [of byte](fp.Length)
		fp.Read(Init, 0, fp.Length)
		fp.Close()
		Extension = extension
	
	def Derive(fn as string):
		random = Random()
		max = Init.Length << 2
		buf = array [of byte](Init.Length << 2)
		Array.Copy(Init, buf, Init.Length)
		curlen = Init.Length
		for i in range(random.Next(1, 11)):
			type = random.Next(0, 3)
			if type == 0: # randomly set data
				start = random.Next(0, curlen)
				if random.Next(0, 2) == 0:
					end = random.Next(start, curlen)
				else:
					end = random.Next(start+1, start + 17)
				
				for i in range(end - start):
					buf[start+i] = cast(byte, random.Next(0, 256))
			elif type == 1 and max > curlen: # Randomly insert data
				start = random.Next(0, curlen)
				if random.Next(0, 2) == 0:
					size = random.Next(0, curlen-start) >> 1
				else:
					size = random.Next(1, 17)
				if start + size + size >= max:
					size = (max - start) >> 1
				
				if size == 0:
					continue
				Array.Copy(buf, start, buf, start+size, size)
				for i in range(size):
					buf[start+i] = cast(byte, random.Next(0, 256))
				curlen += size
			elif type == 2: # Randomly delete data
				start = random.Next(0, curlen)
				if random.Next(0, 2) == 0:
					size = random.Next(0, curlen-start)
				else:
					size = random.Next(1, 17)
				if size > start:
					size = start
				Array.Copy(buf, start+size, buf, start, size)
				curlen -= size
		
		if curlen > max:
			curlen = max
		
		fp = File.Open(fn, FileMode.Create)
		fp.Write(buf, 0, curlen)
		fp.Close()

class Quicktime(IHarness):
	Files as List [of FileManipulator]
	
	def constructor():
		Files = List [of FileManipulator]()
		for file in Directory.GetFiles('Harnesses\\Quicktime\\Seeds\\'):
			Files.Add(FileManipulator(file, 'pict'))
		Chaos(self)
	
	def Run(chaos as Chaos, i as int, instance as int):
		file = Files[i % Files.Count]
		fn = 'Temp\\test{0}-{1}.{2}' % (instance, i, file.Extension)
		file.Derive(fn)
		
		hit = chaos.Start('Harnesses\\Quicktime\\QTTest.exe', fn)
		if hit != null:
			print fn
			hit.AddFile(fn)
			hit.Send()
		else:
			for i in range(10):
				try:
					File.Delete(fn)
					break
				except:
					Thread.Sleep(1)

Quicktime()
