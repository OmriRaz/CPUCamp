module perf_counter(
        input logic cpu_clk,
        input logic CLK_50,
        input logic resetN,
        input logic [9:0] pixel_x,
        input logic [9:0] pixel_y,
        input logic [15:0] pc,

        output logic perf_drawing_request,
        output logic [7:0] perf_rgb
    );

    parameter NUMBER_OF_DIGITS;
    parameter HEX_DIGIT_WIDTH, HEX_DIGIT_HEIGHT;
    parameter logic [15:0] FINAL_PC;

    int unsigned counter_cpu;
    int unsigned counter_50;
    logic unsigned [13:0] counter_seconds;

    logic finished;
    assign finished = (finished | (pc == FINAL_PC)) && resetN;

    // integer outfile0; //file descriptor
    // integer line;
    // integer counter;
    // initial
    // begin

    //     outfile0=$fopen("memory/rom.txt","r");
    //     //read line by line.
    //     while (! $feof(outfile0)) //read until an "end of file" is reached.
    //     begin
    //         $fgets(line, outfile0);
    //         counter++;
    //     end
    //     $fclose(outfile0);
    // end

    // do the counting
    always_ff @(negedge resetN or posedge cpu_clk)
        if (!resetN)
        begin
            counter_cpu <= 0;
        end
        else
        begin
            if (cpu_clk)
                if ((counter_cpu < 2**32 - 1) && !finished)
                    counter_cpu <= counter_cpu + 1;
        end
    always_ff @(negedge resetN or posedge CLK_50)
        if (!resetN)
        begin
            counter_50 <= 0;
            counter_seconds <= 7'b0;
        end
        else
        begin
            if (CLK_50)
                if ((counter_50 < 2**32 - 1) && !finished)
                begin
                    counter_50 <= counter_50 + 1;
                    if (counter_50 % 500_000 == 500_000 - 1)
                        counter_seconds++;
                end
        end



    // global assignments
    logic clks_drawing_request, seconds_drawing_request;
    assign perf_drawing_request = clks_drawing_request | seconds_drawing_request;
    logic [7:0] clks_rgb, seconds_rgb;
    always_comb
    begin
        if (clks_drawing_request)
            perf_rgb = clks_rgb;
        else
            perf_rgb = seconds_rgb;
    end

    // clks counter
    logic [9:0] offsetX_clks;
    logic [9:0] offsetY_clks;
    logic inside_rectangle_clks;

    logic [3:0] current_digit_clks;
    assign current_digit_clks = 4'((counter_cpu >> (4*((HEX_DIGIT_WIDTH*NUMBER_OF_DIGITS - pixel_x) / HEX_DIGIT_WIDTH))) % 16);

    square_object #(.OBJECT_WIDTH_X(HEX_DIGIT_WIDTH*NUMBER_OF_DIGITS), .OBJECT_HEIGHT_Y(HEX_DIGIT_HEIGHT))
                  cycle_counter_square(
                      .pixelX(pixel_x),// current VGA pixel
                      .pixelY(pixel_y),
                      .topLeftX(0), //position on the screen
                      .topLeftY(384),

                      .offsetX(offsetX_clks),// offset inside bracket from top left position
                      .offsetY(offsetY_clks),
                      .inside_rectangle(inside_rectangle_clks) // indicates pixel inside the bracket
                  );
    numbers_bitmap #(.digit_color(8'b111_111_11))
                   cycle_counter_bitmap(
                       .offsetX(offsetX_clks),
                       .offsetY(offsetY_clks),
                       .InsideRectangle(inside_rectangle_clks),
                       .digit(current_digit_clks),

                       .drawingRequest(clks_drawing_request),
                       .RGBout(clks_rgb)
                   );


    // seconds counter
    logic [9:0] offsetX_seconds;
    logic [9:0] offsetY_seconds;
    logic inside_rectangle_seconds;

    logic [3:0] current_digit_seconds;
    // assign current_digit_seconds = (counter_seconds >> (4*((HEX_DIGIT_WIDTH*3 - pixel_x) / HEX_DIGIT_WIDTH))) % 16;
    always_comb
    begin
        if (pixel_x < 16)
            current_digit_seconds = 4'((counter_seconds / 10000) % 10);
        else if (pixel_x < 32)
            current_digit_seconds = 4'((counter_seconds / 1000) % 10);
        else if (pixel_x < 48)
            current_digit_seconds = 4'((counter_seconds / 100) % 10);
        else if (pixel_x < 64)
            current_digit_seconds = 4'((counter_seconds / 10) % 10);
        else
            current_digit_seconds = 4'((counter_seconds / 1) % 10);
    end


    square_object #(.OBJECT_WIDTH_X(HEX_DIGIT_WIDTH*5), .OBJECT_HEIGHT_Y(HEX_DIGIT_HEIGHT))
                  seconds_counter_square(
                      .pixelX(pixel_x),// current VGA pixel
                      .pixelY(pixel_y),
                      .topLeftX(0), //position on the screen
                      .topLeftY(384+32),

                      .offsetX(offsetX_seconds),// offset inside bracket from top left position
                      .offsetY(offsetY_seconds),
                      .inside_rectangle(inside_rectangle_seconds) // indicates pixel inside the bracket
                  );
    numbers_bitmap #(.digit_color(8'b111_111_11))
                   seconds_counter_bitmap(
                       .offsetX(offsetX_seconds),
                       .offsetY(offsetY_seconds),
                       .InsideRectangle(inside_rectangle_seconds),
                       .digit(current_digit_seconds),

                       .drawingRequest(seconds_drawing_request),
                       .RGBout(seconds_rgb)
                   );

endmodule
