module comblogic(
    input logic[5:0] op,
    input logic[31:0] a, b,
    input logic[5:0] sa,
    output logic[31:0] r
);

logic[31:0] mux1;
logic[31:0] mux2;
logic[31:0] mux3;
logic[31:0] mux4;
logic[31:0] mux5;
logic[31:0] mux6;
logic[31:0] isand;
logic[31:0] isor;
logic[31:0] isxor;
logic[31:0] issll;
logic[31:0] isslv;
logic[31:0] issrl;
logic[31:0] issrlv;


logic andf;
logic orf;
logic xorf;
logic sll;
logic slv;
logic srl;
logic srlv;

assign andf = (op == 6'b100100 ? 1:0);
assign orf = (op == 6'b100101 ? 1:0);
assign xorf = (op == 6'b100110 ? 1:0);
assign sll = (op == 6'b000000 ? 1:0);
assign slv = (op == 6'b000100 ? 1:0);
assign srl = (op == 6'b000010 ? 1:0);
assign srlv = (op == 6'b000110 ? 1:0);

and32 and1(
    .a(a),
    .b(b),
    .r(isand)
);

or32 or1(
    .a(a),
    .b(b),
    .r(isor)
);

xor32 xor1(
    .a(a),
    .b(b),
    .r(isxor)
);

sll sll_notv(
    .v(1'b0),
    .a(a),
    .b(b),
    .sa(sa),
    .r(issll)
);

sll sll_v(
    .v(1'b1),
    .a(a),
    .b(b),
    .sa(sa),
    .r(isslv)
);

srl srl_notv(
    .v(1'b0),
    .a(a),
    .b(b),
    .sa(sa),
    .r(issrl)
);

srl srl_v(
    .v(1'b1),
    .a(a),
    .b(b),
    .sa(sa),
    .r(issrlv)
);

assign mux1 = (andf == 1 ? isand : 0);
assign mux2 = (orf == 1 ? isor : mux1);
assign mux3 = (xorf == 1 ? isxor : mux2);
assign mux4 = (sll == 1 ? issll : mux3);
assign mux5 = (slv == 1 ? isslv : mux4);
assign mux6 = (srl == 1 ? issrl : mux5);
assign r = (srlv == 1 ? issrlv : mux6);


endmodule


