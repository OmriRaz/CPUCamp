@3163
D = A
@id1
M = D
@9161
D = A
@id2
M = D
//==========================

@id1
D = M
@addend1
M = D
@id2
D = M
@addend2
M = D
//==========================

@555 //start number
D = A
@1 //result
M = D

@32767 //loop count
D = A
@counter //counter
M = D

@32767
D = A
@400 //bit mask, 0111...111
M = D

@100 //number of stages
D = A
@stage
M = D


(LOOP)

@counter
M = M - 1

// load return address
@CONT
D = A
@100
M = D

// load arg1
@1
D = M
@101
M = D
// load arg2
@addend1
D = M
@102
M = D

// call
@ADD
0;JMP

(CONT)
@201 // low word
D = M
@1 //low result
M = D
@200 //carry
D = M
@0
M = M + D //add carry


@counter
D = M
@LOOP
D ;JGT

// setup for next stage
@0
D = M
M = 0
@2
M = D
@1
M = M + D

@32767 //loop count
D = A
@counter //counter
M = D

//rotate addends
@addend1
D = M
@addend_temp
M = D + 1 //addend_temp = addend1 + 1

@addend2
D = M
@addend1
M = D //addend1 = addend2

@addend_temp
D = M
@addend2
M = D //addend2 = addend_temp

//decrement stage
@stage
MD = M - 1
@LOOP
D; JGT

//==================== END
@END
0;JMP


//====== function add - adds two words with carry
//@100 - return address
//@101 - first arg
//@102 - second arg
//@200 - carry
//@201 - sum
//@300 - scratch
//@400 - mask (0111...111)
(ADD)
@101
D = M
@31 //masked arg1
M = D
@102
D = D + M
@201
M = D
@300 //masked sum
M = D


@101
D = M
@NO_NEG
D;JGE

@201
D = M
@400
D = D&M
@300 //masked sum
M = D

@101
D = M
@400
D = D&M
@31 //masked arg1
M = D

(NO_NEG)
@31
D = M
@300
D = D - M //arg1 - sum
@200
M = 0
@NO_OF
D;JLE // arg1 <= sum
@200
M = 1

(NO_OF)
@100
A = M
0;JMP //ret

(END)
@END
0;JMP // Infinite loop