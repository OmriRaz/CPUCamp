module vga(
        input     CLK_50,
        input  [3:0]  SW,
        output [2:0]  RED,
        output [2:0]  GREEN,
        output [1:0]  BLUE,
        output      h_sync,
        output    v_sync
    );

    reg [32:0] countersound = 0;
    reg sound = 0;
    assign SPEAKER = sound;

    always @(posedge CLK_50)
    begin
        if(countersound <= 50000)
            countersound = countersound + 1;
        else
        begin
            sound = ~sound;
            countersound = 0;
        end
    end


    wire InDisplayArea;
    wire [9:0] CounterX;
    wire [9:0] CounterY;
    reg [2:0] R_val = 3'b000;
    reg [2:0] G_val = 3'b000;
    reg [1:0] B_val = 2'b00;
    reg [8:0] redvalue = 0;


    assign RED[2:0] = R_val[2:0];
    assign GREEN[2:0] = G_val[2:0];
    assign BLUE[1:0] = B_val[1:0];


    sync_gen sync_inst(
                 .clk(CLK_50),
                 .vga_h_sync(h_sync),
                 .vga_v_sync(v_sync),
                 .CounterX(CounterX),
                 .CounterY(CounterY),
                 .InDisplayArea(InDisplayArea)
             );

    reg [7:0] pixel = 8'b00000000;
    /*assign RED[2:0] = pixel [7:5];
    assign GREEN[2:0] = pixel [4:2];
    assign BLUE[1:0] = pixel [1:0];*/
    reg [3:0] count = 4'b0000;



    //=============================//
    //  Clock Divider         //
    //=============================//

    reg [32:0] counter = 0;
    reg state = 0;

    always @ (posedge CLK_50)
    begin
        counter <= counter + 1;
        if(counter == 50000)
        begin
            state <= ~state;
            counter <= 0;
        end
    end

    always @(state)
    begin
        if(count < 4'b0100)
            count = count + 1;
        else
            count = 4'b000;
    end
    //==========================//


    always @(posedge CLK_50)
    begin
        if(InDisplayArea)
        begin
            if(SW[0])
                R_val[2:0] = 3'b111;
            else
                R_val[2:0] = 3'b000;

            if(SW[1])
                G_val[2:0] = 3'b111;
            else
                G_val[2:0] = 3'b000;

            if(SW[2])
                B_val[1:0] = 2'b11;
            else
                B_val[1:0] = 2'b00;

            if(SW[3])
            begin
                if(((CounterX > 0) & (CounterX < 213)))
                    R_val[2:0] = 3'b111;
                else if((CounterX > 212) & (CounterX < 426))
                    G_val[2:0] = 3'b111;
                else if(((CounterX > 425) & (CounterX < 640)))
                    B_val[1:0] = 2'b11;
            end
        end
    end
endmodule
