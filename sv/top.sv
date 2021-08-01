module top(
        input     CLK_50,
        input  [3:0]  SW,
        output [2:0]  RED,
        output [2:0]  GREEN,
        output [1:0]  BLUE,
        output      h_sync,
        output    v_sync
    );
    parameter RAM_WIDTH = 16, RAM_REGISTER_COUNT = 16;

    // reg addr
    // ram ram_data(.CPUclk(CLK_50),
    //              .addr(addr),
    //              .rdata(rdata),
    //              .wdata(wdata),
    //              .we(we)
    //             );

    vga vga_inst(.CLK_50(CLK_50),
                 .SW(SW),
                 .RED(RED),
                 .GREEN(GREEN),
                 .BLUE(BLUE),
                 .h_sync(h_sync),
                 .v_sync(v_sync)
                );

endmodule
