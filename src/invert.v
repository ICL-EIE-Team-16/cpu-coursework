module invert(
    /*input logic ctrl,*/
    input logic[31:0] a,
    output logic[31:0] r
);

/*logic[31:0] inv;*/
/*logic[31:0] not_inv;*/

assign r = ~a;
/*assign not_inv = a;

assign r = (ctrl ? inv : not_inv);*/

endmodule