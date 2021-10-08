module cpu (
        input logic         clk,
        input logic         resetN,
        input logic [INSTR_WIDTH-1:0]  inst, // input from rom
        input logic [DATA_WIDTH-1:0]   in_m, // input from ram

        // RAM
        output logic [DATA_WIDTH-1:0] out_m,
        output logic                  write_m,
        output logic [DATA_WIDTH-1:0] data_addr,

        // ROM
        output logic [INSTR_WIDTH-1:0] inst_addr
    );

    parameter DATA_WIDTH, INSTR_WIDTH;

    //////////////////////////////////////////
    // Your implementation here:

endmodule
