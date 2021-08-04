module ram(
        input logic CPUclk, //CPU clock input (default 50MHz)
        input logic [$clog2(REGISTER_COUNT)-1:0] addr,   //RAM address input
        input logic [WIDTH-1:0] wdata,  //Write Data to RAM
        input logic we,      //Write Enable

        input logic [9:0] pixel_x,
        input logic [9:0] pixel_y,

        output logic [WIDTH-1:0] rdata,  //Read Data from RAM
        output logic [WIDTH-1:0] pixel_out
    );

    parameter WIDTH, REGISTER_COUNT, RAM_SCREEN_OFFSET;
    parameter BITS_PER_MEMORY_PIXEL_X;
    parameter BITS_PER_MEMORY_PIXEL_Y;

    localparam WORDS_PER_LINE = (2**9) >> ($clog2(WIDTH)+BITS_PER_MEMORY_PIXEL_X);
    localparam PIXELS_PER_WORD = 2**($clog2(WIDTH)+BITS_PER_MEMORY_PIXEL_X);

    logic [WIDTH-1:0] memory [0:REGISTER_COUNT-1];

    initial
    begin
        // integer i;
        // for(i = RAM_SCREEN_OFFSET; i < RAM_SCREEN_OFFSET+4; i = i + 1)
        // begin
        //     memory[i] = 16'hF00F;
        // end
        memory[RAM_SCREEN_OFFSET + 0]  = 16'hF000;
        memory[RAM_SCREEN_OFFSET + 1]  = 16'h0F00;
        memory[RAM_SCREEN_OFFSET + 2]  = 16'h00F0;
        memory[RAM_SCREEN_OFFSET + 3]  = 16'h0010;
        memory[RAM_SCREEN_OFFSET + 4]  = 16'h000F;
        memory[RAM_SCREEN_OFFSET + 5]  = 16'h0000;
        memory[RAM_SCREEN_OFFSET + 6]  = 16'b1001011101110111;
        memory[RAM_SCREEN_OFFSET + 7]  = 16'b1101001001000100;
        memory[RAM_SCREEN_OFFSET + 8]  = 16'b1011001001000110;
        memory[RAM_SCREEN_OFFSET + 9]  = 16'b1001001001000100;
        memory[RAM_SCREEN_OFFSET + 10] = 16'b1001011101110111;
    end

    always_ff @(posedge CPUclk)
    begin
        if (we)
        begin
            memory[addr] <= wdata;
            rdata <= wdata;
        end
        else
            rdata <= memory[addr];
    end

    always_ff @(posedge CPUclk)
    begin
        pixel_out <= memory[RAM_SCREEN_OFFSET
                            + (pixel_y >> BITS_PER_MEMORY_PIXEL_Y) * WORDS_PER_LINE
                            + ((pixel_x % 512) / PIXELS_PER_WORD)];
    end

endmodule
