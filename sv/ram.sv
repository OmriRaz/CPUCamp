module ram(
        CPUclk, //CPU clock input (default 50MHz)
        addr,   //RAM address input
        rdata,  //Read Data from RAM
        wdata,  //Write Data to RAM
        we      //Write Enable
    );
    parameter WIDTH = 16, REGISTER_COUNT = 16;

    input wire CPUclk, we;
    input wire [7:0] addr;
    input wire[WIDTH-1:0] wdata;
    output wire[WIDTH-1:0] rdata;
    reg[WIDTH-1:0] memory[0:WIDTH*REGISTER_COUNT-1];
    assign rdata = memory[addr];

    always @(posedge CPUclk)
        if (we)
            memory[addr] <= wdata;

endmodule
