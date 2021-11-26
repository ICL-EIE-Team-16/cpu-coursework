module sra(
    input logic v,
    input logic[5:0] sa,
    input logic[31:0] a,
    input logic[31:0] b,
    output logic[31:0] a_out, b_out
);

logic[31:0] shift;
logic[31:0] shift_v;
logic[31:0] in;
logic[31:0] ones;
logic[31:0] zeroes;
logic[31:0] shift_in;
logic[31:0] shift_in_v;


assign ones = 32'hffff;
assign zeroes = 32'h0000;
assign in = (a[31] ? ones : zeroes);

assign shift_in = in<<(31-sa);
assign shift_in_v = in<<(31-b[4:0]);

assign shift = a>>sa;
assign shift_v = a>>b[4:0];

assign a_out = (v ? shift_v : shift);
assign b_out = (v ? shift_in_v : shift_in);

endmodule