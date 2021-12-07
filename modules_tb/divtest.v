module divtest();

logic[3:0]a, b;
logic[3:0] r;

initial begin
    assign a = 4'd9;
    assign b = 4'd3;
    assign r = a%b;
    #1

    $display("result = %d", r);
    $finish;
end

endmodule