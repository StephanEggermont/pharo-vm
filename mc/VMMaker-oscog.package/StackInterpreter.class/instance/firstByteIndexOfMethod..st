compiled methods
firstByteIndexOfMethod: methodObj
	"Answer the one-relative index of the first bytecode in methodObj.
	 Used for safer bounds-checking on methods."
	^(self literalCountOf: methodObj) + LiteralStart * BytesPerWord + 1