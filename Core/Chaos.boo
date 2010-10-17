namespace Chaos

import System
import System.Runtime.InteropServices
import System.Threading

class Chaos:
	[DllImport('kernel32.dll')]
	static def SetThreadAffinityMask(hThread as IntPtr, mask as IntPtr) as IntPtr:
		pass
	
	[DllImport('kernel32.dll')]
	static def GetCurrentThread() as IntPtr:
		pass
	
	def constructor(harness as IHarness):
		self(harness, false)
	
	def constructor(harness as IHarness, once as bool):
		if not once:
			for i in range(Environment.ProcessorCount << 1):
				thread = Thread() do(instance as int):
					Thread.BeginThreadAffinity()
					
					SetThreadAffinityMask(GetCurrentThread(), IntPtr(1 << (instance % Environment.ProcessorCount)))
					
					i = 0
					while i < 250:
						harness.Run(self, i, instance)
						i += 1
					Thread.EndThreadAffinity()
				thread.Start(i)
		else:
			harness.Run(self, 0, 0)
	
	def Start(app as string, *args as (string)):
		debug = Debugger.Start(app, args)
		return debug.Run(false)
	
	def Start(timeoutHit as bool, app as string, *args as (string)):
		debug = Debugger.Start(app, args)
		return debug.Run(timeoutHit)
