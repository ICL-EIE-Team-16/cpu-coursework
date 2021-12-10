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

endmodule