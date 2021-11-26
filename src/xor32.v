module xor32(
    input logic[31:0] a,
    input logic[31:0] b,
    output logic[31:0] r
);

assign r = a|b;

endmodule