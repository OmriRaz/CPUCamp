

module ProgramCounter(
	input           CLK_50,
	input	[3:0]	SW,
	input	[1:0]	BUTTON,
	output	[6:0]	HEX0,
	output	[6:0]	HEX1,
	output	[6:0]	HEX2,
	output	[7:0]	LED,
	inout	[35:0]	GPIO
);

//=======================//
//     PC reg / wires    //
//=======================//
reg [3:0] Counter = 4'b0000; //4 bit program counter (change this value to jump)
wire CE = 1'b1; //Count Enable (leave 1 as default)
wire CPUclk;
assign CPUclk = CLK_50; 



//======================//
//     4 Bit counter    //
//======================//

always @(posedge CPUclk & CE) begin
    Counter = Counter + 1'b1;
    if(Counter == 4'b1111) begin
        Counter = 4'b0000;
    end
end

endmodule
