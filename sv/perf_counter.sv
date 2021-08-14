module perf_counter(
        input logic CLK_50,
        input logic resetN,
        input logic [9:0] pixel_x,
        input logic [9:0] pixel_y,
        input logic [15:0] pc,

        output logic seconds_drawing_request,
        output logic [7:0] seconds_rgb
    );

    parameter NUMBER_OF_DIGITS;
    parameter HEX_DIGIT_WIDTH, HEX_DIGIT_HEIGHT;
    parameter logic [15:0] FINAL_PC;

    int unsigned counter_cpu;
    int unsigned counter_50;
    logic unsigned [12:0] counter_hund_seconds;

    logic finished;
    assign finished = (finished | (pc == FINAL_PC)) && resetN;

    // do the counting
    always_ff @(negedge resetN or posedge CLK_50)
        if (!resetN)
        begin
            counter_50 <= 0;
            counter_hund_seconds <= 7'b0;
        end
        else
        begin
            if (CLK_50)
                if ((counter_hund_seconds < 2**13 - 1) && !finished)
                begin
                    counter_50 <= (counter_50 + 1) % 500_000;
                    if (counter_50 == 500_000 - 1)
                        counter_hund_seconds++;
                end
        end

    // hundredths of second counter
    logic [9:0] offsetX;
    logic [9:0] offsetY;
    logic inside_rectangle;

    logic [3:0] current_digit;
    // assign current_digit = (counter_hund_seconds >> (4*((HEX_DIGIT_WIDTH*3 - pixel_x) / HEX_DIGIT_WIDTH))) % 16;
    always_comb
    begin
        if (pixel_x < 16)
            current_digit = 4'((counter_hund_seconds / 1000) % 10);
        else if (pixel_x < 32)
            current_digit = 4'((counter_hund_seconds / 100) % 10);
        else if (pixel_x < 48)
            current_digit = 4'((counter_hund_seconds / 10) % 10);
        else
            current_digit = 4'((counter_hund_seconds / 1) % 10);
    end


    square_object #(.OBJECT_WIDTH_X(HEX_DIGIT_WIDTH*4), .OBJECT_HEIGHT_Y(HEX_DIGIT_HEIGHT))
                  seconds_counter_square(
                      .pixelX(pixel_x),// current VGA pixel
                      .pixelY(pixel_y),
                      .topLeftX(0), //position on the screen
                      .topLeftY(384+32),

                      .offsetX(offsetX),// offset inside bracket from top left position
                      .offsetY(offsetY),
                      .inside_rectangle(inside_rectangle) // indicates pixel inside the bracket
                  );
    numbers_bitmap #(.digit_color(8'b111_111_11))
                   seconds_counter_bitmap(
                       .offsetX(offsetX),
                       .offsetY(offsetY),
                       .InsideRectangle(inside_rectangle),
                       .digit(current_digit),

                       .drawingRequest(seconds_drawing_request),
                       .RGBout(seconds_rgb)
                   );

endmodule
