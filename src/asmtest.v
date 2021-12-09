module asmtest();

logic[31:0] a;
logic[31:0] b;
logic[63:0] mult;
logic[4:0] sa;

initial begin
    assign a = 32'hbfc11234;
    assign b = 32'h23441234;
    assign mult = a*b;
    assign sa = 5'b10000;
    #1
    $display("hi=%h, lo=%h", mult[63:32], mult[31:0]);
    $finish;
end

endmodule