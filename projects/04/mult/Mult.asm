// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

@i
M=1
@2
M=0
(LOOP)
    @i
    D=M // D = i
    @1
    D=D-M // D = i - R1
    @END
    D;JGT // if i - R1 > 0
    @0
    D=M // D = R0
    @2
    M=D+M // R2 = R2 + D
    @i
    M=M+1 // i = i + 1
    @LOOP
    0;JMP
(END)
    @END
    0;JMP