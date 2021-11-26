module fadd32(
    input logic cin,
    input logic[31:0] a,
    input logic[31:0] b,
    output logic[31:0] r
);

assign r = a+b+cin;

endmodule