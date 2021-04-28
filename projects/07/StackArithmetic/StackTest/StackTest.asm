// === StackTest.vm ===

// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP0:TRUE
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP0:END
0;JMP
($StackTest.vm:COMP0:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP0:END)

// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP1:TRUE
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP1:END
0;JMP
($StackTest.vm:COMP1:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP1:END)

// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1

// eq
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP2:TRUE
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP2:END
0;JMP
($StackTest.vm:COMP2:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP2:END)

// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP3:TRUE
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP3:END
0;JMP
($StackTest.vm:COMP3:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP3:END)

// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP4:TRUE
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP4:END
0;JMP
($StackTest.vm:COMP4:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP4:END)

// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1

// lt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP5:TRUE
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP5:END
0;JMP
($StackTest.vm:COMP5:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP5:END)

// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP6:TRUE
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP6:END
0;JMP
($StackTest.vm:COMP6:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP6:END)

// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP7:TRUE
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP7:END
0;JMP
($StackTest.vm:COMP7:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP7:END)

// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1

// gt
@SP
AM=M-1
D=M
@SP
AM=M-1
D=M-D
@$StackTest.vm:COMP8:TRUE
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@$StackTest.vm:COMP8:END
0;JMP
($StackTest.vm:COMP8:TRUE)
@SP
A=M
M=-1
@SP
M=M+1
($StackTest.vm:COMP8:END)

// push constant 57
@57
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 31
@31
D=A
@SP
A=M
M=D
@SP
M=M+1

// push constant 53
@53
D=A
@SP
A=M
M=D
@SP
M=M+1

// add
@SP
AM=M-1
D=M
@SP
AM=M-1
M=M+D
@SP
M=M+1

// push constant 112
@112
D=A
@SP
A=M
M=D
@SP
M=M+1

// sub
@SP
AM=M-1
D=M
@SP
AM=M-1
M=M-D
@SP
M=M+1

// neg
@SP
AM=M-1
M=-M
@SP
M=M+1

// and
@SP
AM=M-1
D=M
@SP
AM=M-1
M=M&D
@SP
M=M+1

// push constant 82
@82
D=A
@SP
A=M
M=D
@SP
M=M+1

// or
@SP
AM=M-1
D=M
@SP
AM=M-1
M=M|D
@SP
M=M+1

// not
@SP
AM=M-1
M=!M
@SP
M=M+1
