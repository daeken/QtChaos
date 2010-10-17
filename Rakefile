require 'pp'

class Find
	def initialize(block)
		@include = []
		@exclude = []
		
		instance_eval &block
	end
	
	def include(files)
		files = [files] if not files.is_a? Array
		@include += files
	end
	
	def exclude(files)
		files = [files] if not files.is_a? Array
		@exclude += files
	end
	
	def find
		files = []
		@include.each do |path|
			if path =~ /\.\.\.\//
				(0...10).each do |i|
					files += Dir.glob(path.sub '.../', ('*/'*i))
				end
			elsif path =~ /\*/
				files += Dir.glob path
			else
				files += [path]
			end
		end
		
		files.map! do |file|
			if @exclude.map do |exclude|
						if file[0...exclude.size] == exclude then true
						else false
						end
					end.include? true
				nil
			else file
			end
		end
		files.compact
	end
end

def find(&block)
	Find.new(block).find
end

def cs(out, flags=[], files=[], &block)
	if block != nil
		files += find &block
	end
	deps = files
	files = files.map { |x| x.gsub '/', '\\' }
	
	target = 
		if out =~ /\.dll$/ then 'library'
		elsif out =~ /\.win\.exe$/ then 'winexe'
		else 'exe'
		end
	
	references = files.map do |file|
			if file =~ /\.dll$/ then file
			else nil
			end
		end.compact
	
	files = files.map do |file|
			if references.include? file then nil
			else file
			end
		end.compact
	
	references.map! { |file| "/reference:#{file}" }
	
	deps.reject! { |file| file.index('System.') == 0 }
	
	file out => deps do
		sh 'csc', "/out:#{out}", "/target:#{target}", *references, *flags, *files
	end
	Rake::Task[out].invoke
end

def boo(out, flags=[], files=[], &block)
	if block != nil
		files += find &block
	end
	deps = files
	
	target = 
		if out =~ /\.dll$/ then 'library'
		elsif out =~ /\.win\.exe$/ then 'winexe'
		else 'exe'
		end
	
	references = files.map do |file|
			if file =~ /\.dll$/ then file
			else nil
			end
		end.compact
	
	files = files.map do |file|
			if references.include? file then nil
			else file
			end
		end.compact
	
	references.map! { |file| "-reference:#{file}" }
	
	deps.reject! { |file| file.index('System.') == 0 }
	
	file out => deps do
		sh 'booc', "-o:#{out}", "-target:#{target}", *references, *flags, *files
	end
	Rake::Task[out].invoke
end

task :default => [:harnesses]

task :obj do
	if not FileTest::directory? 'Obj'
		Dir::mkdir 'Obj'
	end
	if not FileTest::directory? 'Temp'
		Dir::mkdir 'Temp'
	end
end

task :chaos => [:obj] do
	cs 'Obj/Chaos.DebugWrap.dll' do
		include 'Core/DebugWrap.cs'
	end
	
	boo 'Obj/Chaos.dll' do
		include [
				'System.Web.dll', 
				'Obj/Chaos.DebugWrap.dll', 
				'Core/.../*.boo'
			]
	end
end

task :harnesses => [:chaos] do
	Dir.glob('Harnesses/*').each do |harness|
		name = harness.split('/')[1]
		boo "Obj/#{name}.exe" do
			include [
					'Obj/Chaos.dll', 
					harness + '/.../*.boo'
				]
		end
		
		sh 'corflags', '/32bit+', "Obj/#{name}.exe"
	end
end

task :tools => [:heaptracer]

task :heaptracer do
	cs 'Obj/HeapTracer.DebugWrap.dll' do
		include 'Tools/HeapTracer/DebugWrap.cs'
	end
	
	boo 'Obj/HeapTracer.exe' do
		include [
				'Obj/HeapTracer.DebugWrap.dll', 
				'Tools/HeapTracer/.../*.boo'
			]
	end
	
	sh 'corflags', '/32bit+', "Obj/HeapTracer.exe"
end
