@20000 //loop count
D = A
@0 //counter
M = D

@7 //start number
D = A
@3 //result
M = D

@5123
D = A
@4 //addend
M = D

@16384
D = A
@16383
D = A + D
@40 //bit mask, 0111...111
M = D


(LOOP)

@0
M = M - 1

// load return address
@CONT
D = A
@10
M = D

// load arg1
@3
D = M
@11
M = D
// load arg2
@4
D = M
@12
M = D

// call
@ADD
0;JMP

(CONT)
@21 // low word
D = M
@3 //low result
M = D
@20 //carry
D = M
@2
M = M + D //add carry


@0
D = M
@LOOP
D ;JGT

(END)
@END
0;JMP // Infinite loop


//====== function add - adds two words with carry
//@11 - first arg
//@12 - second arg
//@20 - carry
//@21 - sum
//@30 - scratch
//@40 - mask (0111...111)
(ADD)
@11
D = M
@31 //masked arg1
M = D
@12
D = D + M
@21
M = D
@30 //masked sum
M = D


@11
D = M
@NO_NEG
D;JGE

@21
D = M
@40
D = D&M
@30 //masked sum
M = D

@11
D = M
@40
D = D&M
@31 //masked arg1
M = D

(NO_NEG)
@31
D = M
@30
D = D - M //arg1 - sum
@20
M = 0
@NO_OF
D;JLE // arg1 <= sum
@20
M = 1

(NO_OF)
@10
A = M
0;JMP //ret