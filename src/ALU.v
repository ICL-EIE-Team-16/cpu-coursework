module ALU(
    input logic[31:0] a, b,
    input logic[5:0] sa,
    input logic[5:0] op,
    output logic zero, positive, negative,
    output logic[31:0] r
);


assign opcode_internal = op;

typedef enum logic[5:0]{
    ADD = 6'b100000,
    SUB = 6'b100010,
    SRA = 6'b000011,
    SRAV = 6'b000111,
    SLT = 6'b101010,
    AND = 6'b100100,
    OR = 6'b100101,
    SLL = 6'b000000,
    SLLV = 6'b000100,
    SRL = 6'b000010,
    SRLV = 6'b000110,
    XOR = 6'b100110
} opcode_internal;


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

    else if(AND) begin
        r = a&b;
    end

    else if(OR) begin
        r = a|b;
    end

    else if(SLL) begin
        r = a<<sa;
    end

    else if(SLLV) begin
        r = a<<b[4:0];
    end

    else if(SRL) begin
        r = a>>sa;
    end

    else if(SRLV) begin
        r = a>>b[4:0];
    end

    else if(XOR) begin
        r = a^b;
    end


end
/*logic[31:0] addsub_out;
logic[31:0] comblogic_out;

addsub addsub1(
    .a(a),
    .b(b),
    .sa(sa),
    .op(op),
    .zero(zero),
    .positive(positive),
    .negative(negative),
    .r(addsub_out)
);

comblogic comblogic1(
    .a(a),
    .b(b),
    .sa(sa),
    .op(op),
    .r(comblogic_out)
);

assign r = (op[3] ? comblogic_out : addsub_out);*/



endmodule