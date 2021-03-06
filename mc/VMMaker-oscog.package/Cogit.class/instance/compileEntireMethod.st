compile abstract instructions
compileEntireMethod
	"Compile the abstract instructions for the entire method, including blocks."
	| result |
	self compileAbort.
	self compileEntry.
	(result := self compilePrimitive) < 0 ifTrue:
		[^result].
	self compileFrameBuild.
	blockCount := 0.
	(result := self compileMethodBody) < 0 ifTrue:
		[^result].
	blockCount = 0 ifTrue:
		[^0].
	(result := self compileBlockBodies) < 0 ifTrue:
		[^result].
	^self compileBlockDispatch