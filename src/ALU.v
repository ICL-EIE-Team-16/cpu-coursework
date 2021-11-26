module ALU(
    input logic[31:0] a, b,
    input logic[5:0] sa,
    input logic[5:0] op,
    output logic zero, positive, negative,
    output logic[31:0] r
);

logic[31:0] addsub_out;
logic[31:0] comblogic_out;

addsub addsub1(
    .a(a),
    .b(b),
    .sa(sa),
    .op(op),
    .zero(zero),
    .positive(positive),
    .negative(negative),
    .r(addsub_out)
);

comblogic comblogic1(
    .a(a),
    .b(b),
    .sa(sa),
    .op(op),
    .r(comblogic_out)
);

assign r = (op[3] ? comblogic_out : addsub_out);

endmodule