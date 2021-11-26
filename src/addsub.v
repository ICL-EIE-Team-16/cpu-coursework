module addsub(
    input logic[31:0] a, b,
    input logic[5:0] sa,
    input logic[5:0] op,
    output logic zero, negative, positive,
    output logic[31:0] r
);

/*logic add;
logic sub;
logic sra;
logic srav;
logic slt;
logic subctrl;*/

/*logic[31:0] mux1;
logic[31:0] mux2;
logic[31:0] mux3;
logic[31:0] mux4;
logic[31:0] mux5;
logic[31:0] a_sra_notv;
logic[31:0] a_sra_v;
logic[31:0] b_sra_notv;
logic[31:0] b_sra_v;
logic[31:0] inv;
logic[31:0] adderout;*/

assign opcode_internal = op;

typedef enum logic[5:0]{
    ADD = 6'b100000,
    SUB = 6'b100010,
    SRA = 6'b000011,
    SRAV = 6'b000111,
    SLT = 6'b101010
} opcode_internal;

/*assign add = (op == 6'b100000 ? 1:0);
assign sub = (op == 6'b100010 ? 1:0);
assign sra = (op == 6'b000011 ? 1:0);
assign srav = (op == 6'b000111 ? 1:0);
assign slt = (op == 6'b101010 ? 1:0);
assign subctrl = slt | sub;*/


/*always @(*) begin
    if(add == 1) begin
        r = a + b;
    end

    else if(sub == 1) begin
        r = a - b;
    end
    else if(sra == 1) begin
        r = a>>>(sa);
    end

    else if(srav == 1) begin
        r = a>>>(b[4:0]);
    end

    else if(slt == 1) begin
        if(a<b)begin
            r = 32'h0001;
        end
        else begin
            r = 32'h0000;
        end
    end

    if(r > 0) begin
        positive = 1;
        zero = 0;
        negative = 0;
    end

    else if(r < 0) begin
        positive = 0;
        zero = 0;
        negative = 1;
    end

    else if(r == 0) begin
        positive = 0;
        zero = 1;
        negative = 0;
    end

end*/

always @(*) begin
    if(ADD) begin
        r = a + b;
    end

    else if(SUB) begin
        r = a - b;
    end
    else if(SRA) begin
        r = a>>>(sa);
    end

    else if(SRAV) begin
        r = a>>>(b[4:0]);
    end

    else if(SLT) begin
        if(a<b)begin
            r = 32'h0001;
        end
        else begin
            r = 32'h0000;
        end
    end

    if(r > 0) begin
        positive = 1;
        zero = 0;
        negative = 0;
    end

    else if(r < 0) begin
        positive = 0;
        zero = 0;
        negative = 1;
    end

    else if(r == 0) begin
        positive = 0;
        zero = 1;
        negative = 0;
    end

end






/*sra notv(
    .v(1'b0),
    .sa(sa),
    .a(a),
    .b(b),
    .a_out(a_sra_notv),
    .b_out(b_sra_notv)
);

sra isv(
    .v(1'b1),
    .sa(sa),
    .a(a),
    .b(b),
    .a_out(a_sra_v),
    .b_out(b_sra_v)
);

invert inv1(
    .a(b),
    .r(inv)
);


assign mux1 = (sra ? a_sra_notv : a);
assign mux2 = (srav ? a_sra_v : mux1);

assign mux3 = (subctrl ? inv : b);
assign mux4 = (sra ? b_sra_notv : mux3); 
assign mux5 = (srav ? b_sra_v : mux4);


fadd32 adder(
    .cin(subctrl),
    .a(mux2),
    .b(mux5),
    .r(adderout)
);

assign zero = (adderout == 0 ? 1 : 0);
assign positive = (adderout[31] == 0 ? 1 : 0);
assign negative = (adderout[31] == 1 ? 1 : 0);

assign r = (slt == 1 ? (negative == 1 ? 32'h0001 : 32'h0000) : adderout);*/


endmodule
