module ram(
        input logic CPUclk, //CPU clock input (default 50MHz)
        input logic [$clog2(REGISTER_COUNT)-1:0] addr,   //RAM address input
        input logic [WIDTH-1:0] wdata,  //Write Data to RAM
        input logic we,      //Write Enable

        input logic [3:0] SW, //temp

        input logic [9:0] pixel_x,
        input logic [9:0] pixel_y,

        output logic [WIDTH-1:0] rdata,  //Read Data from RAM
        output logic [WIDTH-1:0] pixel_out
    );
    parameter WIDTH = 16, REGISTER_COUNT = 2**15, RAM_SCREEN_OFFSET = 16384;

    logic [WIDTH-1:0] memory [0:REGISTER_COUNT-1];

    always_ff @(posedge CPUclk)
    begin
        if (SW[0])
        begin
            memory[RAM_SCREEN_OFFSET + 7] <= 16'b1010_1010_1010_1010;
        end

        if (we)
            memory[addr] <= wdata;
        rdata <= memory[addr];
        pixel_out <= memory[RAM_SCREEN_OFFSET + (pixel_y*64/WIDTH)];
    end

endmodule
