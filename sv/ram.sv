module ram(
        input logic cpu_clk, //CPU clock input (default 50MHz)
        input logic CLK_50, //50MHz clock (for VGA)
        input logic [$clog2(REGISTER_COUNT)-1:0] addr,   //RAM address input
        input logic [WIDTH-1:0] wdata,  //Write Data to RAM
        input logic we,      //Write Enable

        input logic [$clog2(REGISTER_COUNT)-1:0] addr_screen,


        output logic [WIDTH-1:0] rdata,  //Read Data from RAM
        output logic [WIDTH-1:0] rdata_screen
    );

    parameter WIDTH, REGISTER_COUNT, RAM_SCREEN_OFFSET;

    logic [WIDTH-1:0] memory [0:REGISTER_COUNT-1];

    // initial
    // begin
    //     $readmemh("memory/ram.txt", memory, RAM_SCREEN_OFFSET);
    // end

    always_ff @(posedge cpu_clk)
    begin
        if (we)
        begin
            memory[addr] <= wdata;
        end
    end

    assign rdata = memory[addr];

    always_ff @(posedge CLK_50)
    begin
        rdata_screen <= memory[RAM_SCREEN_OFFSET + addr_screen];
    end

endmodule
