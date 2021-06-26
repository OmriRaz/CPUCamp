module ram(
    CPUclk, //CPU clock input (default 50MHz)
    addr,   //RAM address input
    rdata,  //Read Data from RAM
    wdata,  //Write Data to RAM
    we      //Write Enable
);
input wire CPUclk, we;
input wire [7:0] addr;
input wire[15:0] wdata;
output wire[15:0] rdata;
reg[15:0] memory[0:255];
assign rdata = memory[addr];

always @(posedge CPUclk)
if (we)
    memory[addr] <= wdata;

endmodule
