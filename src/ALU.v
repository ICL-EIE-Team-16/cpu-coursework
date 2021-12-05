module ALU(
    input logic[31:0] a, b,
    input logic[6:0] op,
    input logic[5:0] sa,
    input logic fetch, exec1, exec2, clk,
    output logic zero, positive, negative,
    output logic[31:0] r, hi, lo
);

logic[63:0] mult_intermediate;
logic[31:0] hi_next, lo_next;

typedef enum logic[6:0]{
    ADD = 7'd1,
    ADDI = 7'd2,
    ADDIU = 7'd3,
    ADDU = 7'd4,
    AND = 7'd5,
    ANDI = 7'd6,
    DIV = 7'd7,
    DIVU = 7'd8,
    MFHI = 7'd9,
    MFLO = 7'd10,
    MTHI = 7'd11,
    MTLO = 7'd12,
    MULT = 7'd13,
    MULTU = 7'd14,
    OR = 7'd15,
    ORI = 7'd16,
    SLL = 7'd17,
    SLLV = 7'd18,
    SLT = 7'd19,
    SLTI = 7'd20,
    SLTIU = 7'd21,
    SLTU = 7'd22,
    SRA = 7'd23,
    SRAV = 7'd24,
    SRL = 7'd25,
    SRLV = 7'd26,
    SUBU = 7'd27,
    XOR = 7'd28,
    XORI = 7'd29,
    BEQ = 7'd30,
    BGEZ = 7'd31,
    BGEZAL = 7'd32,
    BGTZ = 7'd33,
    BLEZ = 7'd34,
    BLTZ = 7'd35,
    BLTZAL = 7'd36,
    BNE = 7'd37,
    J = 7'd38,
    JAL = 7'd39,
    JALR = 7'd40,
    JR = 7'd41,
    LB = 7'd42,
    LBU = 7'd43,
    LH = 7'd44,
    LHU = 7'd45,
    LUI = 7'd46,
    LW = 7'd47,
    LWL = 7'd48,
    LWR = 7'd49,
    SB = 7'd50,
    SH = 7'd51,
    SW = 7'd52
} opcode_decode;





always @(*) begin
    

    if(op == ADDU) begin
        r = a+b;
    end

    if(op == ADDIU) begin
        r = a+b;
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

    if(op == MULTU) begin
        mult_intermediate = a*b;
        lo_next = mult_intermediate[31:0];
        hi_next = mult_intermediate[63:32];
    end 

    if(op == DIVU) begin
        lo_next = a/b;
        hi_next = a%b;
    end

    if(r > 0) begin
        positive = 1;
        zero = 0;
        negative = 0;
    end

    if(r == 32'h0000) begin
        positive = 0;
        zero = 1;
        negative = 0;
    end

    if(a < b && op == SUBU) begin
        positive = 0;
        negative = 1;
        zero = 0;
    end
end

always_ff @(posedge clk) begin

    if(op == MULTU)begin
        lo <= lo_next;
        hi <= hi_next;
    end
    if(op == DIVU)begin
        lo <= lo_next;
        hi <= hi_next;
    end
end




endmodule