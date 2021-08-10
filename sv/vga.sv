module vga(
        input logic CLK_50,
        input logic [DATA_WIDTH-1:0] pixel_in,
        input logic [3:0]  SW,
        input logic number_drawing_request,
        input logic [7:0]  number_rgb,

        output logic [2:0] RED,
        output logic [2:0] GREEN,
        output logic [1:0] BLUE,
        output logic h_sync,
        output logic v_sync,
        output logic [9:0] pixel_x,
        output logic [9:0] pixel_y
    );

    parameter DATA_WIDTH;
    parameter BITS_PER_MEMORY_PIXEL_X;
    parameter BITS_PER_MEMORY_PIXEL_Y;
    parameter HEX_START_X;
    parameter PIXELS_PER_HEX_DIGIT_X;

    localparam PIXELS_PER_WORD = 2**($clog2(DATA_WIDTH)+BITS_PER_MEMORY_PIXEL_X);

    logic inDisplayArea;

    sync_gen sync_inst(
                 .clk(CLK_50),
                 .vga_h_sync(h_sync),
                 .vga_v_sync(v_sync),
                 .CounterX(pixel_x),
                 .CounterY(pixel_y),
                 .inDisplayArea(inDisplayArea)
             );


    //==========================//


    always_ff @(posedge CLK_50)
    begin
        if (inDisplayArea)
        begin
            if (SW[3])
            begin
                RED   <= 3'b111;
                GREEN <= 3'b000;
                BLUE  <= 2'b00;
            end
            else
            begin
                // off pixel
                RED   <= 3'b001;
                GREEN <= 3'b001;
                BLUE  <= 2'b01;

                // on pixel
                if (pixel_in[(PIXELS_PER_WORD - (pixel_x % PIXELS_PER_WORD)) >> BITS_PER_MEMORY_PIXEL_X])
                begin
                    RED   <= 3'b111;
                    GREEN <= 3'b111;
                    BLUE  <= 2'b11;
                end

                // pixel border
                if (((pixel_x % (2**BITS_PER_MEMORY_PIXEL_X)) == 0) || ((pixel_y % (2**BITS_PER_MEMORY_PIXEL_Y)) == 0))
                begin
                    RED   <= 3'b111;
                    GREEN <= 3'b000;
                    BLUE  <= 2'b00;
                end

                // byte border
                if ((pixel_x % (2**(BITS_PER_MEMORY_PIXEL_X+3))) == 0)
                begin
                    RED   <= 3'b000;
                    GREEN <= 3'b000;
                    BLUE  <= 2'b01;
                end

                // word border
                if ((pixel_x % (2**(BITS_PER_MEMORY_PIXEL_X+4))) == 0)
                begin
                    RED   <= 3'b000;
                    GREEN <= 3'b000;
                    BLUE  <= 2'b11;
                end

                // out of boundary
                if ((pixel_x >= HEX_START_X) || (pixel_y >= 384))
                begin
                    // background
                    RED   <= 3'b000;
                    GREEN <= 3'b001;
                    BLUE  <= 2'b00;

                    // number
                    if (number_drawing_request)
                    begin
                        RED   <= number_rgb[7:5];
                        GREEN <= number_rgb[4:2];
                        BLUE  <= number_rgb[1:0];
                    end

                    // byte border (2 hex digits)
                    if ((pixel_x - HEX_START_X) % (2*PIXELS_PER_HEX_DIGIT_X) == 0 && pixel_y < 384)
                    begin
                        RED   <= 3'b000;
                        GREEN <= 3'b000;
                        BLUE  <= 2'b01;
                    end

                    // word border (4 hex digits)
                    if ((pixel_x - HEX_START_X) % (4*PIXELS_PER_HEX_DIGIT_X) == 0 && pixel_y < 384)
                    begin
                        RED   <= 3'b000;
                        GREEN <= 3'b000;
                        BLUE  <= 2'b11;
                    end
                end
            end
        end
        else
        begin
            RED   <= 3'b000;
            GREEN <= 3'b000;
            BLUE  <= 2'b00;
        end

    end
endmodule
