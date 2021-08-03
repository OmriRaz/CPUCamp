module top(
        input     CLK_50,
        input  [3:0]  SW,
        output [2:0]  RED,
        output [2:0]  GREEN,
        output [1:0]  BLUE,
        output      h_sync,
        output    v_sync
    );
    parameter BITS_PER_MEMORY_PIXEL_X = 5;
    parameter BITS_PER_MEMORY_PIXEL_Y = 5;
    parameter RAM_WIDTH = 16, RAM_REGISTER_COUNT = 2**15, RAM_SCREEN_OFFSET = 16384;

    logic [$clog2(RAM_REGISTER_COUNT)-1:0] addr;
    logic we;
    logic [RAM_WIDTH-1:0] rdata;

    assign addr = 0;
    assign we = 0;

    logic [9:0] pixel_x;
    logic [9:0] pixel_y;
    logic [RAM_WIDTH-1:0] pixel_value;

    // assign pixel_value = 16'hFFFF;

    ram #(.WIDTH(RAM_WIDTH), .REGISTER_COUNT(RAM_REGISTER_COUNT), .RAM_SCREEN_OFFSET(RAM_SCREEN_OFFSET),
          .BITS_PER_MEMORY_PIXEL_X(BITS_PER_MEMORY_PIXEL_X), .BITS_PER_MEMORY_PIXEL_Y(BITS_PER_MEMORY_PIXEL_Y))
        ram_data(.CPUclk(CLK_50),
                 .SW(SW), //temp
                 .addr(addr),
                 .rdata(rdata),
                 //  .wdata(wdata),
                 .pixel_x(pixel_x),
                 .pixel_y(pixel_y),
                 .we(we),
                 .pixel_out(pixel_value)
                );

    vga #(.RAM_WIDTH(RAM_WIDTH), .BITS_PER_MEMORY_PIXEL_X(BITS_PER_MEMORY_PIXEL_X), .BITS_PER_MEMORY_PIXEL_Y(BITS_PER_MEMORY_PIXEL_Y))
        vga_inst(.CLK_50(CLK_50),
                 .SW(SW), //temp
                 .RED(RED),
                 .GREEN(GREEN),
                 .BLUE(BLUE),
                 .h_sync(h_sync),
                 .v_sync(v_sync),
                 .pixel_x(pixel_x),
                 .pixel_y(pixel_y),
                 .pixel_in(pixel_value)
                );

endmodule
