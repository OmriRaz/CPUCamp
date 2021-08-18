`define USE_PLL

module top(
        input     CLK_50,
        input  [3:0]  SW,
        input  [1:0] BUTTON,
        output [2:0]  RED,
        output [2:0]  GREEN,
        output [1:0]  BLUE,
        output      h_sync,
        output    v_sync
    );
    parameter DATA_WIDTH = 16, RAM_REGISTER_COUNT = 2**12, RAM_SCREEN_OFFSET = 0;
    parameter ROM_REGISTER_COUNT = 2**12;
    parameter NUMBER_OF_DIGITS_PERF = 8;
    parameter logic [15:0] FINAL_PC = 16'(ROM_REGISTER_COUNT-1);

    // max settings that worked for me:
    // kiwi -       280/100
    // de10-lite -  260/100
    parameter PLL_MULTIPLY = 250;
    parameter PLL_DIVIDE = 100;


    parameter BITS_PER_MEMORY_PIXEL_X = 4; //4
    parameter BITS_PER_MEMORY_PIXEL_Y = 5; //5
    parameter HEX_START_X = 512;
    parameter HEX_DIGIT_WIDTH = 16;
    parameter HEX_DIGIT_HEIGHT = 32;

    // The number of bits shown will be (2**(9-BITS_PER_MEMORY_PIXEL_X))*(384/(2**(BITS_PER_MEMORY_PIXEL_Y)))

    localparam HEX_DIGITS_PER_LINE = BITS_PER_MEMORY_PIXEL_X <= 4 ? 8 : 4;
    localparam WORDS_PER_LINE = (2**9) >> ($clog2(DATA_WIDTH)+BITS_PER_MEMORY_PIXEL_X);
    localparam PIXELS_PER_WORD = 2**($clog2(DATA_WIDTH)+BITS_PER_MEMORY_PIXEL_X);
    localparam BITS_PER_HEX_DIGIT = 4;
    localparam WORDS_PER_HEX_LINE = BITS_PER_HEX_DIGIT * HEX_DIGITS_PER_LINE / DATA_WIDTH;
    localparam HEX_PIXELS_PER_WORD = DATA_WIDTH / BITS_PER_HEX_DIGIT * HEX_DIGIT_WIDTH;

    //PLL
    logic cpu_clk;

`ifdef USE_PLL

    pll	#(.MULTIPLY(PLL_MULTIPLY), .DIVIDE(PLL_DIVIDE))
        pll_inst(
            .inclk0 ( CLK_50 ),
            .c0 ( cpu_clk )
        );
`else
    assign cpu_clk = CLK_50;
`endif

    //===
    logic [$clog2(RAM_REGISTER_COUNT)-1:0] ram_address;
    logic we;
    logic [DATA_WIDTH-1:0] rdata;

    logic [9:0] pixel_x;
    logic [9:0] pixel_y;
    logic [DATA_WIDTH-1:0] word_value;

    logic [DATA_WIDTH-1:0] word_address;

    logic resetN;
    assign resetN = BUTTON[0];

    always_comb
    begin
        // Binary
        if (pixel_x < HEX_START_X)
            word_address = DATA_WIDTH'((pixel_y >> BITS_PER_MEMORY_PIXEL_Y) * WORDS_PER_LINE
                                       + (pixel_x / PIXELS_PER_WORD));
        // HEX
        else
            word_address = DATA_WIDTH'((pixel_y / HEX_DIGIT_HEIGHT) * WORDS_PER_HEX_LINE
                                       + ((pixel_x - HEX_START_X) / HEX_PIXELS_PER_WORD));
    end

    ram #(.WIDTH(DATA_WIDTH), .REGISTER_COUNT(RAM_REGISTER_COUNT), .RAM_SCREEN_OFFSET(RAM_SCREEN_OFFSET))
        ram_data(.cpu_clk(cpu_clk),
                 .CLK_50(CLK_50),
                 .resetN(resetN),
                 .addr(ram_address),
                 .rdata(rdata),
                 .wdata(cpu_out_m),
                 .we(we),
                 .addr_screen(word_address),
                 .rdata_screen(word_value)
                );

    vga #(.DATA_WIDTH(DATA_WIDTH), .BITS_PER_MEMORY_PIXEL_X(BITS_PER_MEMORY_PIXEL_X), .BITS_PER_MEMORY_PIXEL_Y(BITS_PER_MEMORY_PIXEL_Y),
          .HEX_START_X(HEX_START_X), .HEX_DIGIT_WIDTH(HEX_DIGIT_WIDTH))
        vga_inst(.CLK_50(CLK_50),
                 .hex_drawing_request(hex_drawing_request),
                 .hex_rgb(hex_rgb),
                 .perf_drawing_request(perf_drawing_request),
                 .perf_rgb(perf_rgb),
                 .SW(SW), //temp
                 .pixel_in(word_value),

                 .RED(RED),
                 .GREEN(GREEN),
                 .BLUE(BLUE),
                 .h_sync(h_sync),
                 .v_sync(v_sync),
                 .pixel_x(pixel_x),
                 .pixel_y(pixel_y)
                );

    // HEX (NOT 7 Segment, but display on screen)
    logic hex_drawing_request;
    logic [7:0] hex_rgb;
    hex_display #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .HEX_DIGITS_PER_LINE(HEX_DIGITS_PER_LINE),
                    .HEX_DIGIT_WIDTH(HEX_DIGIT_WIDTH),
                    .HEX_START_X(HEX_START_X),
                    .HEX_PIXELS_PER_WORD(HEX_PIXELS_PER_WORD)
                )
                hex_display_inst(
                    .pixel_x(pixel_x),
                    .pixel_y(pixel_y),
                    .word_value(word_value),

                    .hex_drawing_request(hex_drawing_request),
                    .hex_rgb(hex_rgb)
                );

    // performance counter
    logic perf_drawing_request;
    logic [7:0] perf_rgb;
    perf_counter #(
                     .NUMBER_OF_DIGITS(NUMBER_OF_DIGITS_PERF),
                     .HEX_DIGIT_WIDTH(HEX_DIGIT_WIDTH),
                     .HEX_DIGIT_HEIGHT(HEX_DIGIT_HEIGHT),
                     .FINAL_PC(FINAL_PC)
                 )
                 perf_counter_inst(
                     .CLK_50(CLK_50),
                     .resetN(resetN),
                     .pixel_x(pixel_x),
                     .pixel_y(pixel_y),
                     .pc(inst_address),

                     .perf_drawing_request(perf_drawing_request),
                     .perf_rgb(perf_rgb)
                 );



    //CPU AND ROM
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] cpu_out_m;
    logic [$clog2(ROM_REGISTER_COUNT)-1:0] inst_address;

    rom #(.WIDTH(DATA_WIDTH), .REGISTER_COUNT(ROM_REGISTER_COUNT))
        rom_inst (
            .addr(inst_address),
            .q(instruction)
        );


    cpu cpu_inst (
            .clk(cpu_clk),
            .SW(SW),
            .inst(instruction),
            .in_m(rdata),
            .resetN(resetN),

            .out_m(cpu_out_m),
            .write_m(we),
            .data_addr(ram_address),
            .inst_addr(inst_address)
        );
endmodule
