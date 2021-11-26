module sll(
    input logic v,
    input logic[5:0] sa,
    input logic[31:0] a,
    input logic[31:0] b,
    output logic[31:0] r
);

logic[31:0] shift;
logic[31:0] shift_v;

assign shift = a<<sa;
assign shift_v = a<<b[4:0];

assign r = (v ? shift_v : shift);

endmodule


