module rom
    (
        input cpu_clk,
        input [$clog2(REGISTER_COUNT)-1:0] addr,
        output reg [WIDTH-1:0] q
    );
    parameter WIDTH, REGISTER_COUNT;

    reg [WIDTH-1:0] rom [0:REGISTER_COUNT-1];

    // initial
    // begin
    //     $readmemb("rom.txt", rom);
    // end


    always @ (posedge cpu_clk)
    begin
        q <= rom[addr];
    end

endmodule
