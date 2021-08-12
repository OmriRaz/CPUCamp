// Adds 1+...+100.
@i // i refers to some mem. location.
M=1 // i=1
@sum // sum refers to some mem. location.
M=0 // sum=0
(LOOP)
@i
D=M // D=i
@100
D=D-A // D=i-100
@END
D;JGT // If (i-100)>0 goto END
@i
D=M // D=i
@sum
M=D+M // sum=sum+i
@i
M=M+1 // i=i+1
@LOOP
0;JMP // Goto LOOP
(END)
@END
0;JMP // Infinite loop