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
    parameter RAM_WIDTH = 16, RAM_REGISTER_COUNT = 2**8, RAM_SCREEN_OFFSET = 0;
    parameter HEX_START_X = 528;

    logic [$clog2(RAM_REGISTER_COUNT)-1:0] addr;
    logic we;
    logic [RAM_WIDTH-1:0] rdata;

    assign addr = 0;
    assign we = 0;

    logic [9:0] pixel_x;
    logic [9:0] pixel_y;
    logic [RAM_WIDTH-1:0] pixel_value;

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
                 .number_drawing_request(number_drawing_request),
                 .number_rgb(number_rgb),
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

    logic [9:0] offsetX;
    logic [9:0] offsetY;
    logic inside_rectangle;
    logic number_drawing_request;
    logic [7:0] number_rgb;
    logic [7:0] current_nibble;
    always_comb
    begin
        if (pixel_x < HEX_START_X+16*1)
            current_nibble = pixel_value[15:12];
        else if (pixel_x < HEX_START_X+16*2)
            current_nibble = pixel_value[11:8];
        else if (pixel_x < HEX_START_X+16*3)
            current_nibble = pixel_value[7:4];
        else
            current_nibble = pixel_value[3:0];
    end

    square_object #(.OBJECT_WIDTH_X(16*4), .OBJECT_HEIGHT_Y(32*12)) number_square(
                      .clk(CLK_50),
                      .resetN(SW[3]),
                      .pixelX(pixel_x),// current VGA pixel
                      .pixelY(pixel_y),
                      .topLeftX(HEX_START_X), //position on the screen
                      .topLeftY(0),

                      .offsetX(offsetX),// offset inside bracket from top left position
                      .offsetY(offsetY),
                      .inside_rectangle(inside_rectangle) // indicates pixel inside the bracket
                  );
    numbers_bitmap #(.digit_color(8'b111_111_11)) number_bitmap(
                       .clk(CLK_50),
                       .resetN(SW[3]),
                       .offsetX(offsetX),
                       .offsetY(offsetY),
                       .InsideRectangle(inside_rectangle),
                       .digit(current_nibble),

                       .drawingRequest(number_drawing_request),
                       .RGBout(number_rgb)
                   );

endmodule
