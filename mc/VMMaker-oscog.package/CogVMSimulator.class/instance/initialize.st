initialization
initialize
	"Initialize the StackInterpreterSimulator when running the interpreter
	 inside Smalltalk. The primary responsibility of this method is to allocate
	 Smalltalk Arrays for variables that will be declared as statically-allocated
	 global arrays in the translated code."

	| objectMemoryClass |

	"initialize class variables"
	objectMemory ifNotNil:
		[^self halt].

	objectMemoryClass := self class objectMemoryClass.

	objectMemoryClass initBytesPerWord: objectMemoryClass bytesPerWord.
	((Smalltalk classNamed: #CoInterpreterMT) ifNil: [CoInterpreter] ifNotNil: [:cimt| cimt])  initialize.
	(self class cogitClass withAllSuperclasses copyUpThrough: Cogit) reverseDo:
		[:c| c initialize].

	super initialize.
	objectMemory := objectMemoryClass simulatorClass new.
	cogit := self class cogitClass new setInterpreter: self.
	cogit numRegArgs > 0 ifTrue:
		[debugStackDepthDictionary := Dictionary new].
	objectMemory coInterpreter: self cogit: cogit.

	"Note: we must initialize ConstMinusOne & HasBeenReturnedFromMCPC differently
	 for simulation, due to the fact that the simulator works only with +ve 32-bit values"
	ConstMinusOne := objectMemory integerObjectOf: -1.
	HasBeenReturnedFromMCPC := objectMemory integerObjectOf: -1.
	cogMethodZone := cogit methodZone. "Because Slang can't remove intermediate implicit receivers (cogit methodZone foo doesn't reduce to foo())"
	enableCog := true.

	methodCache := Array new: MethodCacheSize.
	atCache := Array new: AtCacheTotalSize.
	self flushMethodCache.
	self flushAtCache.
	cogCompiledCodeCompactionCalledFor := false.
	gcSemaphoreIndex := 0.
	externalSemaphoreSignalRequests := externalSemaphoreSignalResponses := #().
	externalPrimitiveTable := CArrayAccessor on: (Array new: MaxExternalPrimitiveTableSize).
	externalPrimitiveTableFirstFreeIndex := 0.
	primitiveTable := self class primitiveTable copy.
	pluginList := #().
	mappedPluginEntries := OrderedCollection new.
	desiredNumStackPages := desiredEdenBytes := desiredCogCodeSize := 0.
	"This is initialized on loading the image, but convenient for testing stack page values..."
	numStackPages := self defaultNumStackPages. 
	startMicroseconds := Time totalSeconds * 1000000.
	maxLiteralCountForCompile := MaxLiteralCountForCompile.
	minBackwardJumpCountForCompile := MinBackwardJumpCountForCompile.
	flagInterpretedMethods := false.

	"initialize InterpreterSimulator variables used for debugging"
	byteCount := lastPollCount := sendCount := 0.
	quitBlock := [^ self].
	traceOn := true.
	printSends := printFrameAtEachStep := printBytecodeAtEachStep := false.
	myBitBlt := BitBltSimulator new setInterpreter: self.
	transcript := Transcript.
	displayForm := 'Display has not yet been installed' asMorph imageForm.
	suppressHeartbeatFlag := deferSmash := deferredSmash := false.
	systemAttributes := Dictionary new.
	primTraceLog := CArrayAccessor on: (Array new: 256 withAll: 0).
	primTraceLogIndex := 0.
	traceLog := CArrayAccessor on: (Array new: TraceBufferSize withAll: 0).
	traceLogIndex := 0.
	traceSources := TraceSources.
	statCodeCompactionCount := 0.
	statCodeCompactionUsecs := 0.
	extSemTabSize := 256