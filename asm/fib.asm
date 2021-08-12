@0
M = 0

@1
M = 1

@2
M = 0

(LOOP)
@1
D = M
@0
M = D + M

@0
D = M
@1
M = D + M

@2
M = M + 1
D = M
@10
D = D - A
@LOOP
D ;JLT

(END)
@END
0;JMP // Infinite loop