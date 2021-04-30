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
@comparison:1:true
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@comparison:1:end
0;JMP
(comparison:1:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:1:end)

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
@comparison:2:true
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@comparison:2:end
0;JMP
(comparison:2:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:2:end)

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
@comparison:3:true
D;JEQ
@SP
A=M
M=0
@SP
M=M+1
@comparison:3:end
0;JMP
(comparison:3:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:3:end)

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
@comparison:4:true
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@comparison:4:end
0;JMP
(comparison:4:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:4:end)

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
@comparison:5:true
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@comparison:5:end
0;JMP
(comparison:5:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:5:end)

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
@comparison:6:true
D;JLT
@SP
A=M
M=0
@SP
M=M+1
@comparison:6:end
0;JMP
(comparison:6:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:6:end)

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
@comparison:7:true
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@comparison:7:end
0;JMP
(comparison:7:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:7:end)

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
@comparison:8:true
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@comparison:8:end
0;JMP
(comparison:8:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:8:end)

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
@comparison:9:true
D;JGT
@SP
A=M
M=0
@SP
M=M+1
@comparison:9:end
0;JMP
(comparison:9:true)
@SP
A=M
M=-1
@SP
M=M+1
(comparison:9:end)

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
