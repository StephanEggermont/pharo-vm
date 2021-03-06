initialization
genMustBeBooleanTrampolineFor: boolean called: trampolineName
	"This can be entered in one of two states, depending on SendNumArgsReg. See
	 e.g. genJumpIf:to:.  If SendNumArgsReg is non-zero then this has been entered via
	 the initial test of the counter in the jump executed count (i.e. the counter has
	 tripped).  In this case TempReg contains the boolean to be tested and should not
	 be offset, and ceCounterTripped should be invoked with the unoffset TempReg.
	 If SendNumArgsReg is zero then this has been entered for must-be-boolean
	 processing. TempReg has been offset by boolean and must be corrected and
	 ceSendMustBeBoolean: invoked with the corrected value."
	<var: #trampolineName type: #'char *'>
	| jumpMBB |
	<var: #jumpMBB type: #'AbstractInstruction *'>
	<inline: false>
	opcodeIndex := 0.
	self CmpCq: 0 R: SendNumArgsReg.
	jumpMBB := self JumpZero: 0.
	self compileTrampolineFor: #ceCounterTripped:
		callJumpBar: true
		numArgs: 1
		arg: TempReg
		arg: nil
		arg: nil
		arg: nil
		saveRegs: false
		resultReg: nil.
	"If the objectRepresentation does want true & false to be mobile then we need to record these addresses."
	self assert: (objectRepresentation shouldAnnotateObjectReference: boolean) not.
	jumpMBB jmpTarget: (self AddCq: boolean R: TempReg).
	^self genTrampolineFor: #ceSendMustBeBoolean:
		called: trampolineName
		callJumpBar: true
		numArgs: 1
		arg: TempReg
		arg: nil
		arg: nil
		arg: nil
		saveRegs: false
		resultReg: nil
		appendOpcodes: true