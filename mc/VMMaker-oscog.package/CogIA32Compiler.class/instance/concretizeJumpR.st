generate machine code
concretizeJumpR
	| reg |
	reg := self concreteRegister: (operands at: 0).
	machineCode
		at: 0 put: 16rFF;
		at: 1 put: (self mod: ModReg RM: reg RO: 4).
	^machineCodeSize := 2