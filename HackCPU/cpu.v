module CPU(
input 		MAX10_CLK1_50,
output	[7:0]	HEX0,
output	[7:0]	HEX1,
output	[7:0]	HEX2,
output	[7:0]	HEX3,
output	[7:0]	HEX4,
output	[7:0]	HEX5,
input 	[1:0]	KEY,
output	[9:0]	LEDR,
input 	[9:0]	SW,
inout 	[35:0]	GPIO
);


wire CPUclk = MAX10_CLK1_50;
assign LEDR[9:0] = alu_out[9:0]; //assign the first 10 bits of the result to the LEDs
assign nrst = ~KEY[0]; //assign CPU reset to the KEY0 button on the DE10 Lite
assign alu_fn[5:0] = SW[5:0]; //assign the function selection of the ALU to the 6 switches on the DE10 Lite
//////////////////////////////////////////

wire nrst; //input
wire [15:0] inst; //input
wire [15:0] rdata; //input
wire [14:0] inst_addr, data_addr; //output
wire [15:0] wdata; //output
wire we; //output


reg[14:0] pc;
reg[15:0] a = 16'b0000000000000111; //test data for the ALU
reg[15:0] d = 16'b0000000000101110; //test data for the ALU

//ALU module instantiation
alu alu0(
  .x(d),
  .y(a),
  .out(alu_out),
  .fn(alu_fn),
  .zero(zero)
); 

wire load_a = 0;//!inst[15] || inst[5];
wire load_d = 0;//inst[15] && inst[4];
wire sel_a = inst[15];
wire sel_am = inst[12]; //select if the ALU's Y input is from ram or from A register
wire jump = (less_than_zero && inst[2]) || (zero && inst[1]) || (greater_than_zero && inst[0]);
wire sel_pc = inst[15] && jump;
wire zero; //zero flag from ALU
wire less_than_zero = alu_out[15];
wire greater_than_zero = !(less_than_zero || zero);
wire[14:0] next_pc = sel_pc ? a[14:0] : pc + 15'b1;
wire[15:0] next_a = sel_a ? alu_out : {1'b0, inst[14:0]};
wire[15:0] next_d = alu_out;
wire[15:0] am = sel_am ? m : a; // decide wether the alu will use the data in memory or in the A register
wire[15:0] alu_out; 
wire[5:0] alu_fn;//= inst[11:6]; //function for the ALU 
wire[15:0] m = rdata;

assign inst_addr = pc;
assign data_addr = a[14:0];
assign wdata = alu_out;
assign we = inst[15] && inst[3];


always @(posedge CPUclk)
if (!nrst)
    pc <= 15'b0;
else
    pc <= next_pc;


always @(posedge CPUclk)
if (load_a)
    a <= next_a;

always @(posedge CPUclk)
if (load_d)
    d <= next_d;

endmodule
