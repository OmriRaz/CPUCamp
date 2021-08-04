module CPU(
        input logic         clk,
        input logic [1:0]   KEY,
        input logic [3:0]   SW,
        input logic [15:0]  inst,
        input logic [15:0]  in_m,
        input logic         resetN,

        output logic [15:0] out_m,
        output logic        write_m,
        output logic [14:0] data_addr,
        output logic [14:0] inst_addr
    );

    //////////////////////////////////////////
    logic [14:0] pc;
    logic [15:0] a = 16'b0000000000000111; //test data for the ALU
    logic [15:0] d = 16'b0000000000101110; //test data for the ALU

    //ALU module instantiation
    alu alu0(
            .x(d),
            .y(am),
            .out(alu_out),
            .fn(alu_fn),
            .zero(zero)
        );

    logic load_a = !inst[15] || inst[5];
    logic load_d = inst[15] && inst[4];
    logic sel_a = inst[15];
    logic sel_am = inst[12]; //select if the ALU's Y input is from ram or from A register
    logic jump = (less_than_zero && inst[2]) || (zero && inst[1]) || (greater_than_zero && inst[0]);
    logic sel_pc = inst[15] && jump;
    logic zero; //zero flag from ALU
    logic less_than_zero = alu_out[15];
    logic greater_than_zero = !(less_than_zero || zero);
    logic [14:0] next_pc = sel_pc ? a[14:0] : pc + 15'b1;
    logic [15:0] next_a = sel_a ? alu_out : {1'b0, inst[14:0]};
    logic [15:0] next_d = alu_out;
    logic [15:0] am = sel_am ? m : a; // decide whether the alu will use the data in memory or in the A register
    logic [15:0] alu_out;
    logic [5:0] alu_fn = inst[11:6]; //function for the ALU
    logic [15:0] m = in_m;
    assign data_addr = a[14:0];
    assign out_m = alu_out;
    assign write_m = inst[15] && inst[3];
    assign inst_addr = pc;

    always @(posedge clk)
        if (!resetN)

            pc <= 15'b0;
        else
            pc <= next_pc;


    always @(posedge clk)
        if (load_a)
            a <= next_a;

    always @(posedge clk)
        if (load_d)
            d <= next_d;

endmodule
