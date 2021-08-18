module rom
    (
        // input cpu_clk,
        input [$clog2(REGISTER_COUNT)-1:0] addr,
        output reg [WIDTH-1:0] q
    );
    parameter WIDTH, REGISTER_COUNT;

    reg [WIDTH-1:0] rom [0:REGISTER_COUNT-1];

    initial
    begin
        $readmemb("memory/rom.txt", rom);
    end


    assign q = rom[addr];


endmodule
