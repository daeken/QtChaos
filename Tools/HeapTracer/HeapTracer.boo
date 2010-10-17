class HeapTracer:
	def constructor(args as (string)):
		debugger = Debugger(*args)
		debugger.SetPreHook("ntdll", "RtlAllocateHeap")
		debugger.SetPostHook("ntdll", "RtlAllocateHeap") 

HeapTracer(argv)
