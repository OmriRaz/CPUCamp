module vga(
        input logic    CLK_50,
        input logic  [15:0] pixel_in,
        input logic [3:0]  SW,

        output logic [2:0] RED,
        output logic [2:0] GREEN,
        output logic [1:0] BLUE,
        output logic h_sync,
        output logic v_sync,
        output logic [9:0] pixel_x,
        output logic [9:0] pixel_y
    );

    logic inDisplayArea;
    // logic [2:0] R_val = 3'b000;
    // logic [2:0] G_val = 3'b000;
    // logic [1:0] B_val = 2'b00;


    // assign RED[2:0] = R_val[2:0];
    // assign GREEN[2:0] = G_val[2:0];
    // assign BLUE[1:0] = B_val[1:0];


    sync_gen sync_inst(
                 .clk(CLK_50),
                 .vga_h_sync(h_sync),
                 .vga_v_sync(v_sync),
                 .CounterX(pixel_x),
                 .CounterY(pixel_y),
                 .inDisplayArea(inDisplayArea)
             );



    //=============================//
    //  Clock Divider         //
    //=============================//

    reg [32:0] counter = 0;
    reg state = 0;

    always_ff @ (posedge CLK_50)
    begin
        counter <= counter + 1;
        if(counter == 50000)
        begin
            state <= ~state;
            counter <= 0;
        end
    end

    //==========================//


    always_ff @(posedge CLK_50)
    begin
        if (inDisplayArea)
        begin
            GREEN[2:0] <= 3'b101;
            BLUE[1:0] <= 2'b11;
            if(SW[0])
                RED[2:0] <= 3'b100;
            else
                RED[2:0] <= 3'b000;

            // if(SW[0])
            //     R_val[2:0] = 3'b111;
            // else
            //     R_val[2:0] = 3'b000;

            // if(SW[1])
            //     G_val[2:0] = 3'b111;
            // else
            //     G_val[2:0] = 3'b000;

            // if(SW[2])
            //     B_val[1:0] = 2'b11;
            // else
            //     B_val[1:0] = 2'b00;

            // if(SW[3])
            // begin
            //     if(((pixel_x > 0) & (pixel_x < 213)))
            //         R_val[2:0] = 3'b011;
            //     else if((pixel_x > 212) & (pixel_x < 426))
            //         G_val[2:0] = 3'b111;
            //     else if(((pixel_x > 425) & (pixel_x < 640)))
            //         B_val[1:0] = 2'b11;
            // end

            // if(SW[0])
            // begin
            //     R_val[2:0] = 3'b111;
            //     G_val[2:0] = 3'b111;
            //     B_val[1:0] = 2'b11;
            // end
            // else
            // begin
            //     R_val[2:0] = 3'b000;
            //     G_val[2:0] = 3'b000;
            //     B_val[1:0] = 2'b00;
            // end

            // R_val = pixel_in[pixel_x%16] * 7;
            // G_val = pixel_in[pixel_x%16] * 7;
            // B_val = pixel_in[pixel_x%16] * 3;
        end
        else
        begin
            // R_val[2:0] = 3'b000;
            // G_val[2:0] = 3'b000;
            // B_val[1:0] = 2'b00;
            RED[2:0] <= 3'b000;
            GREEN[2:0] <= 3'b000;
            BLUE[1:0] <= 2'b00;
        end

    end
endmodule
