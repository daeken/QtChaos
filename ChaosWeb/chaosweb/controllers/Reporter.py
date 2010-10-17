import datetime, glob, struct

from paste.urlparser import PkgResourcesParser
from pylons import request, response
from pylons.controllers.util import forward
from pylons.middleware import error_document_template
from webhelpers.html.builder import literal

from chaosweb.lib.base import BaseController

class QTParser(object):
	def __init__(self, data):
		self.data = data
		self.off = 0
		
		self.atoms = []
		self.messages = []
		self.atomStack = ['ROOT']
		self.top = len(data)
		
		try:
			while self.off < self.top:
				last = self.off
				self.atoms.append(self.parseAtom(self.top))
				if self.off == last:
					break
		except:
			import traceback
			traceback.print_exc()
	
	def pushAtom(self, fourcc):
		self.atomStack.append(fourcc)
	
	def popAtom(self):
		return self.atomStack.pop()
	
	def log(self, msg):
		self.messages.append(('->'.join(map(repr, self.atomStack)), msg))
	
	def uint32(self):
		if self.top - self.off > 4:
			self.off += 4
			return struct.unpack('>L', self.data[self.off-4:self.off])[0]
		else:
			self.log('Size does not fit')
			raise Exception('Foo')
	
	def parseAtom(self, top):
		oldTop = self.top
		self.top = top
		try:
			size = self.uint32()
			if size-4 > self.off + top:
				self.log('Atom at %08X is larger than the container' % (self.off - 4))
			
			if self.off + 4 > top:
				self.log('Atom at %08X does not have space for a fourcc')
				raise Exception('Foo')
			else:
				fourcc = self.data[self.off:self.off+4]
				self.off += 4
				print fourcc
		except:
			import traceback
			traceback.print_exc()
		
		self.top = oldTop

def parseQT(data):
	parser = QTParser(data)
	return parser.messages, parser.atoms

class ReporterController(BaseController):
	def index(self):
		data = '<ul>'
		for name in glob.glob('reports/*'):
			report = eval(file(name, 'rb').read())
			name = name[8:]
			data += '<li><a href="/Reporter/view?id=%r">%s</a> -- %s</li>' % (name, name, report['eip'])
		data += '</ul>'
		return data
	
	def view(self):
		id = eval(request.params.get('id'))
		report = eval(file('reports/' + id.replace('/', ''), 'rb').read())
		data = '<a href="/Reporter/download?id=%r">Download file</a><br />' % id
		data += '<a href="/Reporter/downloadraw?id=%r">Download raw</a><br />' % id
		data += '<table border="1">'
		names = report.keys()
		names.sort()
		for name in names:
			if name != 'file':
				data += '<tr><td>%s</td><td>%s</td></tr>' % (name, report[name])
		data += '</table>'
		
		data += '<br />'
		if 'fn' in report and report['fn'].endswith('.mov'):
			try:
				messages, atoms = parseQT(''.join(chr(int(report['file'][i:i+2], 16)) for i in range(0, len(report['file']), 2)))
				temp = ''
				temp += '\n'.join(': '.join(msg) for msg in messages)
				data += '<pre>%s</pre>' % (temp.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;'))
			except:
				pass
		
		return data
	
	def download(self):
		id = eval(request.params.get('id')).replace('/', '')
		report = eval(file('reports/' + id, 'rb').read())
		response.headers['Content-type'] = 'application/octet-stream'
		#response.charset = 'utf-8'
		
		if 'fn' not in report:
			fn = id + '.pict'
		else:
			fn = id + '.' + report['fn'].split('.')[-1]
		
		response.headers['Content-disposition'] = 'attachment; filename=' + fn
		return ''.join(chr(int(report['file'][i:i+2], 16)) for i in range(0, len(report['file']), 2))
	
	def downloadraw(self):
		id = eval(request.params.get('id')).replace('/', '')
		report = eval(file('reports/' + id, 'rb').read())
		response.headers['Content-type'] = 'application/octet-stream'
		#response.charset = 'utf-8'
		
		if 'fn' not in report:
			fn = id + '.pict'
		else:
			fn = id + '.' + report['fn'].split('.')[-1]
		
		response.headers['Content-disposition'] = 'attachment; filename=' + fn
		return report['file'].encode('utf-8')
	
	def report(self):
		names = list('code edi esi ebx ecx eax ebp eip eflags esp file fn'.split(' '))
		names += ['info%X' % i for i in range(15)]
		
		params = dict((name, request.params.get(name, None)) for name in names)
		fn = datetime.datetime.now().isoformat(' ').replace(':', '')
		file('reports/' + fn, 'wb').write(`params`)
		data = ''.join(chr(int(params['file'][i:i+2], 16)) for i in range(0, len(params['file']), 2))
		file('binaries/' + fn + '.' + params['fn'].split('.')[-1], 'wb').write(data)
		print 'Hit!'
