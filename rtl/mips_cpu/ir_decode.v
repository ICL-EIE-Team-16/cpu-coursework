module IR_decode(
    input logic clk,
    input logic[31:0] current_instruction,
    input logic is_current_instruction_valid,
    input logic fetch,
    input logic exec1,
    input logic exec2,

    output logic[4:0] shift_amount, // only relevant to r_type instructions
    output logic[4:0] destination_reg,
    output logic[4:0] reg_a_idx_1,
    output logic[4:0] reg_a_idx_2,
    output logic[4:0] reg_b_idx_1,
    output logic[4:0] reg_b_idx_2,
    output logic[31:0] immediate_1, // only relevant to I_type instructions – immediate value (sign extended for ALU so 32 bits long)
    output logic[31:0] immediate_2, // only relevant to I_type instructions – immediate value (sign extended for ALU so 32 bits long)
    output logic[25:0] memory, // only relevant to j_type instructions – memory address
    output logic reg_write_en, // for register files
    output logic[6:0] instruction_code_1,
    output logic[6:0] instruction_code_2
);

    logic r_type_1;
    logic r_type_2;
    logic j_type_1;
    logic j_type_2;
    logic i_type_1;
    logic i_type_2;
    logic[5:0] opcode_1;
    logic[5:0] opcode_2;
    logic[5:0] function_code_1;
    logic[5:0] function_code_2;

    logic[31:0] instruction_1;
    logic[31:0] instruction_1_prev;
    logic[31:0] instruction_2;

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

    } instcode_t;

//Instruction register saving behaviour
    always_ff @(posedge clk) begin
        if (is_current_instruction_valid)
            instruction_2 <= instruction_1;
    end

    always @(*) begin
        if (is_current_instruction_valid)
            instruction_1 = current_instruction;
    end

//Type decode
    always @(*) begin
        opcode_1 = instruction_1[31:26];
        opcode_2 = instruction_2[31:26];

        if (opcode_1 == 6'b000000) begin
            r_type_1 = 1;
            j_type_1 = 0;
            i_type_1 = 0;
        end
        else if (opcode_1 == 6'b000010 || opcode_1 == 6'b000011) begin
            r_type_1 = 0;
            j_type_1 = 1;
            i_type_1 = 0;
        end
        else begin
            r_type_1 = 0;
            j_type_1 = 0;
            i_type_1 = 1;
        end

        if (opcode_2 == 6'b000000) begin
            r_type_2 = 1;
            j_type_2 = 0;
            i_type_2 = 0;
        end
        else if (opcode_2 == 6'b000010 || opcode_2 == 6'b000011) begin
            r_type_2 = 0;
            j_type_2 = 1;
            i_type_2 = 0;
        end
        else begin
            r_type_2 = 0;
            j_type_2 = 0;
            i_type_2 = 1;
        end

    end

//Decode field assignments
    always @(*) begin
        if (r_type_1 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_1 = instruction_1[25:21]; //rs
            reg_b_idx_1 = instruction_1[20:16]; //rt
            function_code_1 = instruction_1[5:0];
            immediate_1 = 0;
            memory = 0;
            //if instruction
        end
        else if (j_type_1 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_1 = 5'd0;
            reg_b_idx_1 = 5'd0;
            function_code_1 = 6'd0;
            immediate_1 = 32'd0;
            memory = instruction_1[25:0];
        end
        else if (i_type_1 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_1 = instruction_1[25:21];
            reg_b_idx_1 = instruction_1[20:16];
            function_code_1 = 6'd0;
            memory = 26'd0;

            //Sign extension logic for immediate - Multiple formats
            if (instruction_code_1 == ANDI || instruction_code_1 == ORI || instruction_code_1 == XORI)
                immediate_1 = {16'd0, instruction_1[15:0]};
            else if (instruction_code_1 == LUI) begin
                immediate_1 = {instruction_1[15:0], 16'd0};
            end
            else
                immediate_1 = {{16{instruction_1[15]}}, instruction_1[15:0]};
        end

        if (r_type_2 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_2 = instruction_2[25:21]; //rs
            reg_b_idx_2 = instruction_2[20:16]; //rt
            destination_reg = instruction_2[15:11]; //rd
            shift_amount = instruction_2[10:6]; //sa
            function_code_2 = instruction_2[5:0];
            immediate_2 = 0;
            //if instruction
        end
        else if (j_type_2 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_2 = 5'd0;
            reg_b_idx_2 = 5'd0;
            shift_amount = 0;
            function_code_2 = 6'd0;
            immediate_2 = 32'd0;

            if (instruction_code_2 == JAL)
                destination_reg = 31;
            else
                destination_reg = 0;
        end
        else if (i_type_2 == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx_2 = instruction_2[25:21];
            reg_b_idx_2 = instruction_2[20:16];
            shift_amount = 0;
            function_code_2 = 6'd0;

            if (instruction_code_2 == BGEZAL || instruction_code_2 == BLTZAL) begin
                destination_reg = 31;
            end
            else begin
                destination_reg = instruction_2[20:16];
            end

            //Sign extension logic for immediate - Multiple formats
            if (instruction_code_2 == ANDI || instruction_code_2 == ORI || instruction_code_2 == XORI)
                immediate_2 = {16'd0, instruction_2[15:0]};
            else if (instruction_code_2 == LUI) begin
                immediate_2 = {instruction_2[15:0], 16'd0};
            end
            else
                immediate_2 = {{16{instruction_2[15]}}, instruction_2[15:0]};
        end
    end

    always @(*) begin //make sure reg file enables go high in the right cycle
        if (r_type_2) begin
            if (instruction_code_2 == MTHI || instruction_code_2 == MTLO || instruction_code_2 == JR)
                reg_write_en = 0;
            else if (instruction_code_2 == MULT || instruction_code_2 == MULTU || instruction_code_2 == DIV || instruction_code_2 == DIVU)
                reg_write_en = 0;
            else
                reg_write_en = 1;
        end
        else if (i_type_2) begin
            //BGEZAL-------------------------------------------  //BLTZAL------------------------------------------   LB-------------------- LBU------------------- LH-------------------  LHU------------------  LUI------------------- LW--------------------  LWL------------------- LWR-------------------
            if ((opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b10001) || (opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b10000) || (opcode_2 == 6'b100000) || (opcode_2 == 6'b100100) || (opcode_2 == 6'b100001) || (opcode_2 == 6'b100101) || (opcode_2 == 6'b001111) || (opcode_2 == 6'b100011) || (opcode_2 == 6'b100010) || (opcode_2 == 6'b100110)) begin
                reg_write_en = 1;
            end
                //ADDI---------------  ADDIU----------------  ANDI-----------------  ORI-------------------  XORI---------------- SLTI----------------- SLTIU-------------
            else if ((opcode_2 == 6'b001000) || (opcode_2 == 6'b001001) || (opcode_2 == 6'b001100) || (opcode_2 == 6'b001101) || (opcode_2 == 6'b001110) || (opcode_2 == 6'b001010) || (opcode_2 == 6'b001011)) begin
                reg_write_en = 1;
            end
            else
                reg_write_en = 0;
        end
        else if (j_type_2 && instruction_code_2 == JAL)
            reg_write_en = 1;
        else
            reg_write_en = 0;

    end

//decoding the instruction code which will replace opcode, rtype, itype and jtype outputs
    always @(*) begin
        if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100000)) instruction_code_1 = ADD;
        else if (opcode_1 == 6'b001000) instruction_code_1 = ADDI;
        else if (opcode_1 == 6'b001001) instruction_code_1 = ADDIU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100001)) instruction_code_1 = ADDU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100100)) instruction_code_1 = AND;
        else if (opcode_1 == 6'b001100) instruction_code_1 = ANDI;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b011010)) instruction_code_1 = DIV;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b011011)) instruction_code_1 = DIVU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b010000)) instruction_code_1 = MFHI;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b010010)) instruction_code_1 = MFLO;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b010001)) instruction_code_1 = MTHI;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b010011)) instruction_code_1 = MTLO;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b011000)) instruction_code_1 = MULT;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b011001)) instruction_code_1 = MULTU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100101)) instruction_code_1 = OR;
        else if (opcode_1 == 6'b001101) instruction_code_1 = ORI;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000000)) instruction_code_1 = SLL;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000100)) instruction_code_1 = SLLV;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b101010)) instruction_code_1 = SLT;
        else if (opcode_1 == 6'b001010) instruction_code_1 = SLTI;
        else if (opcode_1 == 6'b001011) instruction_code_1 = SLTIU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b101011)) instruction_code_1 = SLTU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000011)) instruction_code_1 = SRA;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000111)) instruction_code_1 = SRAV;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000010)) instruction_code_1 = SRL;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b000110)) instruction_code_1 = SRLV;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100011)) instruction_code_1 = SUBU;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b100110)) instruction_code_1 = XOR;
        else if (opcode_1 == 6'b001110) instruction_code_1 = XORI;

        else if (opcode_1 == 6'b000100) instruction_code_1 = BEQ;
        else if ((opcode_1 == 6'b000001) && (instruction_1[20:16] == 5'b00001)) instruction_code_1 = BGEZ;
        else if ((opcode_1 == 6'b000001) && (instruction_1[20:16] == 5'b10001)) instruction_code_1 = BGEZAL;
        else if (opcode_1 == 6'b000111) instruction_code_1 = BGTZ;
        else if (opcode_1 == 6'b000110) instruction_code_1 = BLEZ;
        else if ((opcode_1 == 6'b000001) && (instruction_1[20:16] == 5'b00000)) instruction_code_1 = BLTZ;
        else if ((opcode_1 == 6'b000001) && (instruction_1[20:16] == 5'b10000)) instruction_code_1 = BLTZAL;
        else if (opcode_1 == 6'b000101) instruction_code_1 = BNE;
        else if (opcode_1 == 6'b000010) instruction_code_1 = J;
        else if (opcode_1 == 6'b000011) instruction_code_1 = JAL;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b001001)) instruction_code_1 = JALR;
        else if ((opcode_1 == 6'd0) && (function_code_1 == 6'b001000)) instruction_code_1 = JR;

        else if (opcode_1 == 6'b100000) instruction_code_1 = LB;
        else if (opcode_1 == 6'b100100) instruction_code_1 = LBU;
        else if (opcode_1 == 6'b100001) instruction_code_1 = LH;
        else if (opcode_1 == 6'b100101) instruction_code_1 = LHU;
        else if (opcode_1 == 6'b001111) instruction_code_1 = LUI;
        else if (opcode_1 == 6'b100011) instruction_code_1 = LW;
        else if (opcode_1 == 6'b100010) instruction_code_1 = LWL;
        else if (opcode_1 == 6'b100110) instruction_code_1 = LWR;
        else if (opcode_1 == 6'b101000) instruction_code_1 = SB;
        else if (opcode_1 == 6'b101001) instruction_code_1 = SH;
        else if (opcode_1 == 6'b101011) instruction_code_1 = SW;

        if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100000)) instruction_code_2 = ADD;
        else if (opcode_2 == 6'b001000) instruction_code_2 = ADDI;
        else if (opcode_2 == 6'b001001) instruction_code_2 = ADDIU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100001)) instruction_code_2 = ADDU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100100)) instruction_code_2 = AND;
        else if (opcode_2 == 6'b001100) instruction_code_2 = ANDI;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b011010)) instruction_code_2 = DIV;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b011011)) instruction_code_2 = DIVU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b010000)) instruction_code_2 = MFHI;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b010010)) instruction_code_2 = MFLO;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b010001)) instruction_code_2 = MTHI;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b010011)) instruction_code_2 = MTLO;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b011000)) instruction_code_2 = MULT;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b011001)) instruction_code_2 = MULTU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100101)) instruction_code_2 = OR;
        else if (opcode_2 == 6'b001101) instruction_code_2 = ORI;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000000)) instruction_code_2 = SLL;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000100)) instruction_code_2 = SLLV;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b101010)) instruction_code_2 = SLT;
        else if (opcode_2 == 6'b001010) instruction_code_2 = SLTI;
        else if (opcode_2 == 6'b001011) instruction_code_2 = SLTIU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b101011)) instruction_code_2 = SLTU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000011)) instruction_code_2 = SRA;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000111)) instruction_code_2 = SRAV;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000010)) instruction_code_2 = SRL;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b000110)) instruction_code_2 = SRLV;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100011)) instruction_code_2 = SUBU;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b100110)) instruction_code_2 = XOR;
        else if (opcode_2 == 6'b001110) instruction_code_2 = XORI;

        else if (opcode_2 == 6'b000100) instruction_code_2 = BEQ;
        else if ((opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b00001)) instruction_code_2 = BGEZ;
        else if ((opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b10001)) instruction_code_2 = BGEZAL;
        else if (opcode_2 == 6'b000111) instruction_code_2 = BGTZ;
        else if (opcode_2 == 6'b000110) instruction_code_2 = BLEZ;
        else if ((opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b00000)) instruction_code_2 = BLTZ;
        else if ((opcode_2 == 6'b000001) && (instruction_2[20:16] == 5'b10000)) instruction_code_2 = BLTZAL;
        else if (opcode_2 == 6'b000101) instruction_code_2 = BNE;
        else if (opcode_2 == 6'b000010) instruction_code_2 = J;
        else if (opcode_2 == 6'b000011) instruction_code_2 = JAL;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b001001)) instruction_code_2 = JALR;
        else if ((opcode_2 == 6'd0) && (function_code_2 == 6'b001000)) instruction_code_2 = JR;

        else if (opcode_2 == 6'b100000) instruction_code_2 = LB;
        else if (opcode_2 == 6'b100100) instruction_code_2 = LBU;
        else if (opcode_2 == 6'b100001) instruction_code_2 = LH;
        else if (opcode_2 == 6'b100101) instruction_code_2 = LHU;
        else if (opcode_2 == 6'b001111) instruction_code_2 = LUI;
        else if (opcode_2 == 6'b100011) instruction_code_2 = LW;
        else if (opcode_2 == 6'b100010) instruction_code_2 = LWL;
        else if (opcode_2 == 6'b100110) instruction_code_2 = LWR;
        else if (opcode_2 == 6'b101000) instruction_code_2 = SB;
        else if (opcode_2 == 6'b101001) instruction_code_2 = SH;
        else if (opcode_2 == 6'b101011) instruction_code_2 = SW;
    end

endmodule
