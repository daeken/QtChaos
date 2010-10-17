namespace Chaos

import Chaos.DebugWrap
import System.IO
import System.Net
import System.Text
import System.Web

class Report:
	Debugger as Debugger
	Context as CONTEXT
	Evt as DEBUG_EVENT
	Filename as string
	
	def constructor(debugger as Debugger, context as CONTEXT, evt as DEBUG_EVENT):
		Debugger = debugger
		Context = context
		Evt = evt
	
	def AddFile(fn as string):
		Filename = fn
	
	def Send():
		print 'Hit!'
		request = cast(HttpWebRequest, WebRequest.Create('http://buckley:31337/Reporter/report'))
		request.Method = 'POST'
		request.ContentType = 'application/x-www-form-urlencoded'
		record = Evt.u.Exception.ExceptionRecord
		data = 'code={0:X8}' % (record.ExceptionCode, )
		data += '&edi=0x{0:X8}' % (Context.Edi, )
		data += '&esi=0x{0:X8}' % (Context.Esi, )
		data += '&ebx=0x{0:X8}' % (Context.Ebx, )
		data += '&edx=0x{0:X8}' % (Context.Edx, )
		data += '&ecx=0x{0:X8}' % (Context.Ecx, )
		data += '&eax=0x{0:X8}' % (Context.Eax, )
		data += '&ebp=0x{0:X8}' % (Context.Ebp, )
		data += '&eip=0x{0:X8}' % (Debugger.MapAddress(Context.Eip), )
		data += '&eflags=0x{0:X8}' % (Context.EFlags, )
		data += '&esp=0x{0:X8}' % (Context.Esp, )
		
		data += '&info0={0:X8}' % (record.ExceptionInformation0.ToUInt32(), )
		data += '&info1={0:X8}' % (record.ExceptionInformation1.ToUInt32(), )
		data += '&info2={0:X8}' % (record.ExceptionInformation2.ToUInt32(), )
		data += '&info3={0:X8}' % (record.ExceptionInformation3.ToUInt32(), )
		data += '&info4={0:X8}' % (record.ExceptionInformation4.ToUInt32(), )
		data += '&info5={0:X8}' % (record.ExceptionInformation5.ToUInt32(), )
		data += '&info6={0:X8}' % (record.ExceptionInformation6.ToUInt32(), )
		data += '&info7={0:X8}' % (record.ExceptionInformation7.ToUInt32(), )
		data += '&info8={0:X8}' % (record.ExceptionInformation8.ToUInt32(), )
		data += '&info9={0:X8}' % (record.ExceptionInformation9.ToUInt32(), )
		data += '&infoA={0:X8}' % (record.ExceptionInformation10.ToUInt32(), )
		data += '&infoB={0:X8}' % (record.ExceptionInformation11.ToUInt32(), )
		data += '&infoC={0:X8}' % (record.ExceptionInformation12.ToUInt32(), )
		data += '&infoD={0:X8}' % (record.ExceptionInformation13.ToUInt32(), )
		data += '&infoE={0:X8}' % (record.ExceptionInformation14.ToUInt32(), )
		
		if Filename != null:
			fp = File.OpenRead(Filename)
			size = fp.Length
			buf = array [of byte](size)
			fp.Read(buf, 0, size)
			fp.Close()
			data += '&file='
			for i in range(size):
				data += '{0:X2}' % (buf[i], )
			data += '&fn=' + HttpUtility.UrlEncode(Filename)
		
		byteData = UTF8Encoding.UTF8.GetBytes(data)
		request.ContentLength = byteData.Length
		postStream = request.GetRequestStream()
		postStream.Write(byteData, 0, byteData.Length)
		postStream.Close()
		
		request.GetResponse().Close()
	
	#def Foo():
	#	print 'Potential vulnerability:'
	#	
	#	record = evt.u.Exception.ExceptionRecord
	#	code = record.ExceptionCode
	#	at = MapAddress(context.Eip)
	#	if code == EXCEPTION_ACCESS_VIOLATION:
	#		type = record.ExceptionInformation0.ToUInt32()
	#		addr = record.ExceptionInformation1.ToUInt32()
	#		if type == 1:
	#			print 'Access violation writing to 0x{0:X8} at {1}' % (addr, at)
	#		elif type == 8:
	#			print 'DEP violation at 0x{0:X8}' % (at, )
	#		else:
	#			print 'Access violation reading from 0x{0:X8} at 0x{1}' % (addr, at)
	#	else:
	#		print 'Exception {0:X8} at {1}' % (code, record.ExceptionAddress)
	#	print
