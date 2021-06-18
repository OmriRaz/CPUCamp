module ALU(
	input		CLK_50,
	input	[3:0]	SW,
	input	[1:0]	BUTTON,
	output	[6:0]	HEX0,
	output	[6:0]	HEX1,
	output	[6:0]	HEX2,
	output	[7:0]	LED,
	inout	[35:0]	GPIO
);

reg [7:0] result;
reg [7:0] A = 8'b0001010; // A input of the ALU (8 bits wide
reg [7:0] B = 8'b0000011; // B input of the ALU (8 bits wide
wire [8:0] tmp;
wire [3:0] op;
reg CarryOut = tmp[8];
assign tmp = {1'b0,A} + {1'b0,B}; 
assign invLED  = result; // assign LEDs to result
assign op = invSW; // assign operation to position of switches

//=================================//
// 	     Inverting		   //
//=================================//
wire [3:0] invSW;
wire [7:0] invLED;
assign LED = ~invLED;
assign invSW[3:0] = ~SW[3:0];
  
//================================//
//      Operation Selection       //
//================================//
always @(posedge CLK_50) begin
	case(op)
	4'b0000: //add
		result = A+B;
	4'b0001: //subtract
		result = A-B;
	4'b0010: //multiply
		result = A*B;
	4'b0011: //divide
		result = A/B;
	default: ALU_Result = A + B ; 
	endcase
end
endmodule
