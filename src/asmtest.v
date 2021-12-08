module asmtest();

logic[31:0] a;
logic[31:0] b;

initial begin
    assign a = 32'h00004873;
    assign b = 32'h00002378;
    #1
    $display("r=%h", a-b);
    $finish;
end

endmodule