

module ram(
	CPUclk,
	addr,
	rdata,
	wdata,
	we
);
input wire CPUclk, we;
input wire [7:0] addr;
input wire[15:0] wdata;
output wire[15:0] rdata;
assign rdata = memory[addr];

reg[15:0] memory[0:255];


always @(posedge CPUclk)

if (we)

memory[addr] <= wdata;

endmodule