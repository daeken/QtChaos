namespace Chaos

import System

class Module:
	public ProcessId as uint
	public Process as IntPtr
	public BaseAddress as uint
	public RealBaseAddress as uint
	public Size as uint
	public Name as string
	
	def constructor(pid as uint, process as CREATE_PROCESS_DEBUG_INFO):
		ProcessId = pid
		Process = process.hProcess
		BaseAddress = cast(uint, process.lpBaseOfImage.ToInt32())
		
		if process.hFile != IntPtr.Zero:
			full = DebugWrap.GetFileName(process.hFile).Split(char('\\'))
			Name = full[full.Length-1]
		else:
			Name = 'Unknown module'
		
		FindRealBase()
	
	def constructor(pid as uint, process as IntPtr, dll as LOAD_DLL_DEBUG_INFO):
		ProcessId = pid
		Process = process
		
		BaseAddress = cast(uint, dll.lpBaseOfDll.ToInt32())
		
		if dll.hFile != IntPtr.Zero:
			full = DebugWrap.GetFileName(dll.hFile).Split(char('\\'))
			Name = full[full.Length-1]
		else:
			Name = 'Unknown module'
		
		FindRealBase()
	
	def ReadString(addr as IntPtr):
		buf = DebugWrap.ReadProcessMemory(Process, addr, 1024)
		str = ''
		for i in range(1024):
			if buf[i] == 0:
				break
			str += cast(char, buf[i])
		return str
	
	def GetAddr(addr as uint):
		buf = DebugWrap.ReadProcessMemory(Process, IntPtr(addr), 4)
		return BitConverter.ToUInt32(buf, 0)
	
	def FindRealBase():
		offset = GetAddr(BaseAddress + 60)
		RealBaseAddress = GetAddr(BaseAddress + offset + 24 + 28)
		Size = GetAddr(BaseAddress + offset + 24 + 28 + 28)
