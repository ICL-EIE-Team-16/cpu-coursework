<<<<<<< HEAD:rtl/mips_cpu/asmtest.v
module asmtest();

logic[31:0] a;
logic[31:0] b;
logic[63:0] mult;

initial begin
    assign a = 32'hf000;
    assign b = 32'h1e000;
    assign mult = a*b;
    #1
    $display("hi=%h, lo=%h", mult[63:32], mult[31:0]);
    $finish;
end

=======
module asmtest();

logic[31:0] a;
logic[31:0] b;
logic[63:0] mult;
logic[4:0] sa;
logic signed[31:0] a_signed, b_signed;

initial begin
    assign a = 32'hffff1234;
    assign b = 32'h00001234;
    assign a_signed = a;
    assign b_signed = b;
    assign mult = a*b;
    assign sa = 5'b10000;
    #1
    $display("hi=%h, lo=%h", a%b, a/b);
    $finish;
end

>>>>>>> bus-integration_ALU:src/asmtest.v
endmodule