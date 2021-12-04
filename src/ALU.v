module ALU(
    input logic[31:0] a, b,
    input logic[6:0] op,
    /*input logic[5:0] sa,*/
    /*input logic[5:0] op,*/ //fn code, bits [5:0] of instruction word
    /*input logic[5:0] op_immediate,*/ //bits [31:26] of instruction word
    /*output logic zero, positive, negative,*/
    output logic[31:0] r
);

typedef enum logic[6:0]{
    ADDIU = 7'd3,
    ADDU = 7'd4,
    LW = 7'd47
} opcode_internal;


/*typedef enum logic[5:0]{
    ADDU = 6'b100001,
    ADDIU = 6'b001001,
    SUBU = 6'b100011,
    SRA = 6'b000011,
    SRAV = 6'b000111,
    SLTU = 6'b101011,
    AND = 6'b100100,
    OR = 6'b100101,
    SLL = 6'b000000,
    SLLV = 6'b000100,
    SRL = 6'b000010,
    SRLV = 6'b000110,
    XOR = 6'b100110
} opcode_decode;*/


always @(*) begin
    /*if(op_immediate == 6'b000000) begin

        if(op == ADDU) begin
            r = a + b;
        end

        if(op == SUBU) begin
            r = a - b;
        end
        
        if(op == SRA) begin
            r = a>>>(sa);
        end

        if(op == SRAV) begin
            r = a>>>(b[4:0]);
        end

        if(op == SLTU) begin
            if(a<b)begin
                r = 32'h0001;
            end
            else begin
                r = 32'h0000;
            end
        end

        if(op == AND) begin
            r = a&b;
        end

        if(op == OR) begin
            r = a|b;
        end

        if(op == SLL) begin
            r = a<<sa;
        end

        if(op == SLLV) begin
            r = a<<b[4:0];
        end

        if(op == SRL) begin
            r = a>>sa;
        end

        if(op == SRLV) begin
            r = a>>b[4:0];
        end

        if(op == XOR) begin
            r = a^b;
        end
    end

    if(op_immediate == ADDIU) begin
            r = a + b;
    end

    if(r[31] == 1) begin
        positive = 0;
        zero = 0;
        negative = 1;
    end
        //this will fail in cases where r is positive and larger than 16^3; will have to better distinguish positive from negative results
        //can't use r < 0 as condition as it will never be true

    else if(r > 0) begin
        positive = 1;
        zero = 0;
        negative = 0;
    end

    else if(r == 32'h0000) begin
        positive = 0;
        zero = 1;
        negative = 0;
    end*/

    if(op == ADDU) begin
        r = a+b;
    end

    if(op == ADDIU) begin
        r = a+b;
    end

    if(op == LW) begin
        r = a+b;
    end

    $display("a: %h, b: %h, result: %h", a, b, r);

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