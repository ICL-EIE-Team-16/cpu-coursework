module alu_tb();

logic[31:0] a, b, r;
logic[3:0] op;
logic zero, positive, negative;
logic[5:0] sa;

initial begin
    
    assign a = 32'h0008;
    assign b = 32'h000f;
    assign sa = 6'b000001;
    assign op = 3'b100;

    #1

    $display("r=%d, zero=%d, positive=%d, negative=%d", r, zero, positive, negative);

    $finish;


end



addsub dut(
    .a(a),
    .b(b),
    .r(r),
    .zero(zero),
    .negative(negative),
    .positive(positive),
    .sa(sa),
    .op(op)
);

endmodule