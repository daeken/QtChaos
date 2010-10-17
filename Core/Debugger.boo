namespace Chaos

import Chaos.DebugWrap
import System
import System.Collections.Generic
import System.Runtime.InteropServices
import System.Text

[DllImport('kernel32.dll')]
def DebugActiveProcess(pid as int) as bool:
	pass

class Debugger:
	static EXCEPTION_ACCESS_VIOLATION     = 0xC0000005
	static EXCEPTION_BREAKPOINT           = 0x80000003
	static EXCEPTION_GUARD_PAGE           = 0x80000001
	static EXCEPTION_SINGLE_STEP          = 0x80000004
	static EXCEPTION_WOW64                = 0x4000001F
	
	Process as ProcessInfo
	
	Modules as List [of Module]
	
	static def Start(app as string, args as (string)):
		argstr = ''
		for arg in args:
			argstr += '"{0}" ' % (arg, )
		return Debugger(DebugWrap.CreateAndDebug(app, app + ' ' + argstr))
	
	def constructor(process as ProcessInfo):
		Process = process
		
		Modules = List [of Module]()
	
	def Hide(process as IntPtr, thread as IntPtr):
		context = DebugWrap.GetThreadContext(thread)
		fs = DebugWrap.GetThreadSelector(thread, context.SegFs)
		pibBuf = DebugWrap.ReadProcessMemory(process, fs+0x30, 4)
		pib = BitConverter.ToUInt32(pibBuf, 0)
		debugger = DebugWrap.ReadProcessMemory(process, pib+2, 1)
		if debugger[0] == 1:
			debugger[0] = 0
			DebugWrap.WriteProcessMemory(process, pib+2, debugger)
	
	def MapAddress(addr as uint):
		for module in Modules:
			if module.BaseAddress <= addr and module.BaseAddress + module.Size > addr:
				return '0x{0:X8} in {1}' % (addr - module.BaseAddress + module.RealBaseAddress, module.Name)
		return '0x{0:X8}' % (addr, )
	
	def Run():
		Run(false)
	
	def Run(timeoutHit as bool):
		Hide(Process.hProcess, Process.hThread)
		DebugWrap.ResumeThread(Process.hThread)
		
		threads = Dictionary [of uint, IntPtr]()
		threads[Process.dwThreadId] = Process.hThread
		
		processes = Dictionary [of uint, IntPtr]()
		processes[Process.dwProcessId] = Process.hProcess
		
		hit as Report = null
		done = false
		while not done:
			handled = false
			evt = DebugWrap.WaitForDebugEvent(10000) # Wait 10 seconds
			
			if evt.dwDebugEventCode == 0: # Timeout
				if timeoutHit:
					if evt.dwThreadId == 0:
						context = CONTEXT()
					else:
						context = DebugWrap.GetThreadContext(threads[evt.dwThreadId])
					hit = Report(self, context, evt)
				done = true
			elif evt.dwDebugEventCode == 1: # EXCEPTION_DEBUG_EVENT
				code = evt.u.Exception.ExceptionRecord.ExceptionCode
				if code == EXCEPTION_SINGLE_STEP:
					pass
				elif code == EXCEPTION_BREAKPOINT:
					pass
				elif code == EXCEPTION_WOW64:
					pass
				elif code == 0xE06D7363:
					pass
				else:
					context = DebugWrap.GetThreadContext(threads[evt.dwThreadId])
					hit = Report(self, context, evt)
					handled = true
					done = true
			elif evt.dwDebugEventCode == 2: # CREATE_THREAD_DEBUG_EVENT
				newThread = evt.u.CreateThread
				threadId = evt.dwThreadId
				threads[threadId] = newThread.hThread
				Hide(processes[evt.dwProcessId], newThread.hThread)
			elif evt.dwDebugEventCode == 3: # CREATE_PROCESS_DEBUG_EVENT
				newProcess = evt.u.CreateProcessInfo
				Modules.Add(Module(evt.dwProcessId, newProcess))
				DebugWrap.CloseHandle(newProcess.hFile)
			elif evt.dwDebugEventCode == 4: # EXIT_THREAD_DEBUG_EVENT
				pass
			elif evt.dwDebugEventCode == 5: # EXIT_PROCESS_DEBUG_EVENT
				done = true
			elif evt.dwDebugEventCode == 6: # LOAD_DLL_DEBUG_EVENT
				newDll = evt.u.LoadDll
				Modules.Add(Module(evt.dwProcessId, processes[evt.dwProcessId], newDll))
				DebugWrap.CloseHandle(newDll.hFile)
			elif evt.dwDebugEventCode == 7: # UNLOAD_DLL_DEBUG_EVENT
				addr = evt.u.UnloadDll.lpBaseOfDll.ToUInt32()
				for i in range(Modules.Count):
					module = Modules[i]
					if module.BaseAddress == addr:
						Modules.RemoveAt(i)
						break
			elif evt.dwDebugEventCode == 8: # OUTPUT_DEBUG_STRING_EVENT
				ds = evt.u.DebugString
				if ds.fUnicode == 0:
					bytes = DebugWrap.ReadProcessMemory(processes[evt.dwProcessId], ds.lpDebugStringData.ToUInt32(), ds.nDebugStringLength-1)
					print 'Debug string (ASCII): "{0}"' % (ASCIIEncoding().GetString(bytes), )
				else:
					bytes = DebugWrap.ReadProcessMemory(processes[evt.dwProcessId], ds.lpDebugStringData.ToUInt32(), (ds.nDebugStringLength-1)*2)
					print 'Debug string (unicode): "{0}"' % (UnicodeEncoding().GetString(bytes), )
			else:
				print 'Unhandled debug event:', evt.dwDebugEventCode
			DebugWrap.ContinueDebugEvent(evt, handled)
		
		DebugWrap.TerminateProcess(Process.hProcess, 0)
		DebugWrap.DebugActiveProcessStop(Process.dwProcessId)
		
		#for pair in processes:
		#	if pair.Value != IntPtr.Zero:
		#		DebugWrap.CloseHandle(pair.Value)
		#for pair in threads:
		#	if pair.Value != IntPtr.Zero:
		#		DebugWrap.CloseHandle(pair.Value)
		
		return hit
