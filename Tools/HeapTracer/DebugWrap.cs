using System;
using System.Runtime.InteropServices;
using System.Text;

namespace Chaos {
	[StructLayout(LayoutKind.Sequential)]
	public struct ProcessInfo
	{
		public IntPtr hProcess;
		public IntPtr hThread;
		public int dwProcessId;
		public int dwThreadId;
	}
	
	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	public struct StartupInfo
	{
		public Int32 cb;
		public string lpReserved;
		public string lpDesktop;
		public string lpTitle;
		public Int32 dwX;
		public Int32 dwY;
		public Int32 dwXSize;
		public Int32 dwYSize;
		public Int32 dwXCountChars;
		public Int32 dwYCountChars;
		public Int32 dwFillAttribute;
		public Int32 dwFlags;
		public Int16 wShowWindow;
		public Int16 cbReserved2;
		public IntPtr lpReserved2;
		public IntPtr hStdInput;
		public IntPtr hStdOutput;
		public IntPtr hStdError;
	}
	
	[StructLayout(LayoutKind.Sequential)]
	public struct SecurityAttrs
	{
		public int nLength;
		public IntPtr lpSecurityDescriptor;
		public int bInheritHandle;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct CREATE_THREAD_DEBUG_INFO
	{
		public IntPtr hThread;
		public IntPtr lpThreadLocalBase;
		public IntPtr lpStartAddress;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct CREATE_PROCESS_DEBUG_INFO
	{
		public IntPtr hFile;
		public IntPtr hProcess;
		public IntPtr hThread;
		public IntPtr lpBaseOfImage;
		public uint dwDebugInfoFileOffset;
		public uint nDebugInfoSize;
		public IntPtr lpThreadLocalBase;
		public IntPtr lpStartAddress;
		public IntPtr lpImageName;
		public ushort fUnicode;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct EXIT_THREAD_DEBUG_INFO
	{
		public uint dwExitCode;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct EXIT_PROCESS_DEBUG_INFO
	{
		public uint dwExitCode;
	}

	[StructLayout( LayoutKind.Sequential )]
	public struct LOAD_DLL_DEBUG_INFO
	{
		public IntPtr hFile;
		public IntPtr lpBaseOfDll;
		public uint dwDebugInfoFileOffset;
		public uint nDebugInfoSize;
		public IntPtr lpImageName;
		public ushort fUnicode;
	}

	[StructLayout( LayoutKind.Sequential )]
	public struct UNLOAD_DLL_DEBUG_INFO
	{
		public IntPtr lpBaseOfDll;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct OUTPUT_DEBUG_STRING_INFO
	{
		public IntPtr lpDebugStringData;
		public ushort fUnicode;
		public ushort nDebugStringLength;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct RIP_INFO
	{
		public uint dwError;
		public uint dwType;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct EXCEPTION_RECORD
	{
		public uint ExceptionCode;
		public uint ExceptionFlags;
		public IntPtr ExceptionRecord;
		public IntPtr ExceptionAddress;
		public uint NumberParameters;
		public IntPtr ExceptionInformation0;
		public IntPtr ExceptionInformation1;
		public IntPtr ExceptionInformation2;
		public IntPtr ExceptionInformation3;
		public IntPtr ExceptionInformation4;
		public IntPtr ExceptionInformation5;
		public IntPtr ExceptionInformation6;
		public IntPtr ExceptionInformation7;
		public IntPtr ExceptionInformation8;
		public IntPtr ExceptionInformation9;
		public IntPtr ExceptionInformation10;
		public IntPtr ExceptionInformation11;
		public IntPtr ExceptionInformation12;
		public IntPtr ExceptionInformation13;
		public IntPtr ExceptionInformation14;
	}

	[StructLayout( LayoutKind.Sequential )]
	public struct EXCEPTION_DEBUG_INFO
	{
		public EXCEPTION_RECORD ExceptionRecord;
		public uint dwFirstChance;
	}
	
	[StructLayout( LayoutKind.Explicit )]
	public struct Union
	{
		[FieldOffset( 0 )] public EXCEPTION_DEBUG_INFO Exception;
		[FieldOffset( 0 )] public CREATE_THREAD_DEBUG_INFO CreateThread;
		[FieldOffset( 0 )] public CREATE_PROCESS_DEBUG_INFO CreateProcessInfo;
		[FieldOffset( 0 )] public EXIT_THREAD_DEBUG_INFO ExitThread;
		[FieldOffset( 0 )] public EXIT_PROCESS_DEBUG_INFO ExitProcess;
		[FieldOffset( 0 )] public LOAD_DLL_DEBUG_INFO LoadDll;
		[FieldOffset( 0 )] public UNLOAD_DLL_DEBUG_INFO UnloadDll;
		[FieldOffset( 0 )] public OUTPUT_DEBUG_STRING_INFO DebugString;
		[FieldOffset( 0 )] public RIP_INFO RipInfo;
	}
	
	[StructLayout( LayoutKind.Sequential )]
	public struct DEBUG_EVENT
	{
		public uint dwDebugEventCode;
		public uint dwProcessId;
		public uint dwThreadId;
		public Union u;
	}

	public enum CONTEXT_FLAGS : uint
	{
		CONTEXT_i386 = 0x10000,
		CONTEXT_i486 = 0x10000,   //  same as i386
		CONTEXT_CONTROL = CONTEXT_i386 | 0x01, // SS:SP, CS:IP, FLAGS, BP
		CONTEXT_INTEGER = CONTEXT_i386 | 0x02, // AX, BX, CX, DX, SI, DI
		CONTEXT_SEGMENTS = CONTEXT_i386 | 0x04, // DS, ES, FS, GS
		CONTEXT_FLOATING_POINT = CONTEXT_i386 | 0x08, // 387 state
		CONTEXT_DEBUG_REGISTERS = CONTEXT_i386 | 0x10, // DB 0-3,6,7
		CONTEXT_EXTENDED_REGISTERS = CONTEXT_i386 | 0x20, // cpu specific extensions
		CONTEXT_FULL = CONTEXT_CONTROL | CONTEXT_INTEGER | CONTEXT_SEGMENTS,
		CONTEXT_ALL = CONTEXT_CONTROL | CONTEXT_INTEGER | CONTEXT_SEGMENTS |  CONTEXT_FLOATING_POINT | CONTEXT_DEBUG_REGISTERS |  CONTEXT_EXTENDED_REGISTERS
	}
	
	[StructLayout(LayoutKind.Sequential)]
	public struct FLOATING_SAVE_AREA
	{
		public uint ControlWord; 
		public uint StatusWord; 
		public uint TagWord; 
		public uint ErrorOffset; 
		public uint ErrorSelector; 
		public uint DataOffset;
		public uint DataSelector; 
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 80)] 
		public byte[] RegisterArea; 
		public uint Cr0NpxState; 
	}

	[StructLayout(LayoutKind.Sequential)]
	public struct CONTEXT
	{
		public uint ContextFlags; //set this to an appropriate value 
		// Retrieved by CONTEXT_DEBUG_REGISTERS 
		public uint Dr0;  
		public uint Dr1; 
		public uint Dr2; 
		public uint Dr3; 
		public uint Dr6; 
		public uint Dr7; 
		// Retrieved by CONTEXT_FLOATING_POINT 
		public FLOATING_SAVE_AREA FloatSave; 
		// Retrieved by CONTEXT_SEGMENTS 
		public uint SegGs; 
		public uint SegFs; 
		public uint SegEs; 
		public uint SegDs; 
		// Retrieved by CONTEXT_INTEGER 
		public uint Edi; 
		public uint Esi; 
		public uint Ebx; 
		public uint Edx; 
		public uint Ecx; 
		public uint Eax; 
		// Retrieved by CONTEXT_CONTROL 
		public uint Ebp; 
		public uint Eip; 
		public uint SegCs; 
		public uint EFlags; 
		public uint Esp; 
		public uint SegSs;
		// Retrieved by CONTEXT_EXTENDED_REGISTERS 
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 512)] 
		public byte[] ExtendedRegisters;
	}
	
	[StructLayout(LayoutKind.Sequential)]
	public struct LDT_ENTRY {
		public ushort LimitLow;
		public ushort BaseLow;
		public byte BaseMid;
		public byte Flags1;
		public byte Flags2;
		public byte BaseHi;
	}
	
	public class DebugException : Exception {
	}
	
	public static class DebugWrap {
		public static uint ToUInt32(this IntPtr val) {
			long lval = val.ToInt64();
			return (uint) lval;
		}
		
		[DllImport("kernel32.dll", CharSet=CharSet.Ansi)]
		public static extern bool CreateProcess(
				string lpApplicationName,
				string lpCommandLine, 
				ref SecurityAttrs lpProcessAttributes, 
				ref SecurityAttrs lpThreadAttributes, 
				bool bInheritHandles, 
				uint dwCreationFlags, 
				IntPtr lpEnvironment, 
				string lpCurrentDirectory,
				ref StartupInfo lpStartupInfo, 
				out ProcessInfo lpProcessInformation
			);
		
		public static ProcessInfo CreateAndDebug(string app, string args) {
			ProcessInfo info = new ProcessInfo();
			StartupInfo sinfo = new StartupInfo();
			SecurityAttrs pSec = new SecurityAttrs();
			SecurityAttrs tSec = new SecurityAttrs();
			pSec.nLength = Marshal.SizeOf(pSec);
			tSec.nLength = Marshal.SizeOf(tSec);
			
			bool success = CreateProcess(
					app, args, 
					ref pSec, ref tSec, true, 0x1|0x4, // DEBUG_PROCESS | CREATE_SUSPENDED 
					IntPtr.Zero, null, ref sinfo, out info
				);
			if(success)
				return info;
			else
				throw new DebugException();
		}
		
		[DllImport( "kernel32.dll", EntryPoint = "WaitForDebugEvent" )]
		[return : MarshalAs( UnmanagedType.Bool )]
		public static extern bool WaitForDebugEvent([In] ref DEBUG_EVENT lpDebugEvent, uint dwMilliseconds);
		
		[DllImport("kernel32.dll")]
		public static extern bool ContinueDebugEvent(uint dwProcessId, uint dwThreadId, uint dwContinueStatus);
		
		public static bool ContinueDebugEvent(DEBUG_EVENT evt, bool handled) {
			uint status;
			if(handled)
				status = 0x00010002;
			else
				status = 0x80010001;
			return ContinueDebugEvent(evt.dwProcessId, evt.dwThreadId, status);
		}
		
		public static DEBUG_EVENT WaitForDebugEvent() {
			return WaitForDebugEvent(0xFFFFFFFF);
		}
		
		public static DEBUG_EVENT WaitForDebugEvent(uint timeout) {
			DEBUG_EVENT evt = new DEBUG_EVENT();
			WaitForDebugEvent(ref evt, timeout);
			return evt;
		}
		
		[DllImport("kernel32.dll")]
		public static extern uint ResumeThread(IntPtr hThread);
		
		[DllImport("kernel32.dll")]
		public static extern bool DebugActiveProcessStop(uint dwProcessId);
		
		[DllImport("kernel32.dll", SetLastError=true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);
		
		[DllImport("kernel32.dll")]
		public static extern bool Wow64GetThreadContext(IntPtr hThread, ref CONTEXT lpContext);
		[DllImport("kernel32.dll")]
		public static extern bool GetThreadContext(IntPtr hThread, ref CONTEXT lpContext);
		
		public static CONTEXT GetThreadContext(IntPtr hThread) {
			CONTEXT context = new CONTEXT();
			context.ContextFlags = (uint) CONTEXT_FLAGS.CONTEXT_ALL;
			if(GetThreadContext(hThread, ref context) == false)
				if(Wow64GetThreadContext(hThread, ref context) == false)
					throw new DebugException();
			return context;
		}
		
		[DllImport("kernel32.dll")]
		public static extern bool Wow64GetThreadSelectorEntry(IntPtr hThread, uint dwSelector, out LDT_ENTRY lpSelectorEntry);
		[DllImport("kernel32.dll")]
		public static extern bool GetThreadSelectorEntry(IntPtr hThread, uint dwSelector, out LDT_ENTRY lpSelectorEntry);
		
		public static uint GetThreadSelector(IntPtr hThread, uint dwSelector) {
			LDT_ENTRY entry = new LDT_ENTRY();
			if(GetThreadSelectorEntry(hThread, dwSelector, out entry) == false)
				if(Wow64GetThreadSelectorEntry(hThread, dwSelector, out entry) == false)
					throw new DebugException();
			return (uint) (entry.BaseLow | (entry.BaseMid << 16) | (entry.BaseHi << 24));
		}
		
		[DllImport("kernel32.dll", SetLastError=true)]
		static extern bool ReadProcessMemory( 
				IntPtr hProcess, 
				IntPtr lpBaseAddress,
				[Out()] byte[] lpBuffer, 
				int dwSize, 
				out int lpNumberOfBytesRead
			);
		
		public static byte[] ReadProcessMemory(IntPtr hProcess, uint addr, int size) {
			return ReadProcessMemory(hProcess, new IntPtr(addr), size);
		}
		
		public static byte[] ReadProcessMemory(IntPtr hProcess, IntPtr addr, int size) {
			byte[] buffer = new byte[size];
			int read;
			ReadProcessMemory(hProcess, addr, buffer, size, out read);
			return buffer;
		}
		
		[DllImport("kernel32.dll",SetLastError = true)]
		static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte [] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);
		
		public static bool WriteProcessMemory(IntPtr hProcess, uint lpBaseAddress, byte[] lpBuffer) {
			int written;
			
			return WriteProcessMemory(hProcess, new IntPtr(lpBaseAddress), lpBuffer, (uint) lpBuffer.Length, out written);
		}
		
		[DllImport("kernel32.dll")]
		public static extern uint GetThreadId(IntPtr hThread);
		
		[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
		public static extern IntPtr CreateFileMapping(
				IntPtr hFile,
				IntPtr lpFileMappingAttributes,
				uint flProtect,
				uint dwMaximumSizeHigh,
				uint dwMaximumSizeLow,
				[MarshalAs(UnmanagedType.LPTStr)] string lpName
			);

		[DllImport("kernel32.dll", SetLastError = true)]
		static extern IntPtr MapViewOfFile(
				IntPtr hFileMappingObject,
				uint dwDesiredAccess,
				uint dwFileOffsetHigh,
				uint dwFileOffsetLow,
				uint dwNumberOfBytesToMap
			);
		
		[DllImport("kernel32.dll")]
		static extern bool UnmapViewOfFile(IntPtr view);
		
		[DllImport("kernel32.dll")]
		public static extern bool CloseHandle(IntPtr handle);
		
		[DllImport("psapi.dll", SetLastError = true, CharSet = CharSet.Unicode)]
		static extern int GetMappedFileName(
				IntPtr hProcess, IntPtr view, 
				[Out] StringBuilder filename, uint size
			);
		
		[DllImport("kernel32.dll")]
		static extern IntPtr GetCurrentProcess();
		
		public static string GetFileName(IntPtr hFile) {
			IntPtr mapping = CreateFileMapping(hFile, IntPtr.Zero, 0x02, 0, 1, null);
			IntPtr view = MapViewOfFile(mapping, 0x04, 0, 0, 1);
			int len;
			StringBuilder filename = new StringBuilder(1024);
			len = GetMappedFileName(GetCurrentProcess(), view, filename, 1024);
			UnmapViewOfFile(view);
			CloseHandle(mapping);
			
			return filename.ToString(0, len);
		}
	}
}
