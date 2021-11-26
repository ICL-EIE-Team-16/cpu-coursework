module logic_tb();

logic[31:0] a, b, r;
logic[5:0] sa;
logic[3:0] op;

initial begin
    assign a = 32'h000e;
    assign b = 32'h0001;
    assign sa = 6'b000010;
    assign op = 4'b1110;

    #1

    $display("r=%d", r);
    $finish;
end

comblogic dut(
    .a(a),
    .b(b),
    .sa(sa),
    .r(r),
    .op(op)
);

endmodule