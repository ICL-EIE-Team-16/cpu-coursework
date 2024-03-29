//add in 7 bit instruction code
module IR_decode(
input logic clk,
input logic [31:0] current_instruction, 
input logic fetch,
input logic exec1,
input logic exec2,

output logic [4:0] shift_amount, // only relevant to r_type instructions
output logic [4:0] destination_reg, //register addresses 5 
output logic [4:0] reg_a_idx, // “  
output logic [4:0] reg_b_idx, // ”
output logic [31:0] immediate, // only relevant to I_type instructions – immediate value (sign extended for ALU so 32 bits long) 
output logic [25:0] memory, // only relevant to j_type instructions – memory address 
output logic reg_write_en, // for register files 
output logic [6:0] instruction_code

);  

logic r_type;
logic j_type;
logic i_type;
logic last_exec1;
logic [5:0] opcode;
logic [5:0] function_code;

logic [31:0] saved_instruction;
logic [31:0] instruction; 

typedef enum logic [6:0] {
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
    //Positive edge detection
    last_exec1 <= exec1;

    if (exec1 & ~last_exec1)
        saved_instruction <= current_instruction;

    else
        saved_instruction <= saved_instruction;
end

 always @(*) begin
    if (exec1 & ~last_exec1)
         instruction = current_instruction;
    else
         instruction = saved_instruction;
end

//Type decode
always@(*) begin
    if ((exec1)||(exec2)) begin
        opcode = instruction[31:26];

        if (opcode == 6'b000000) begin
            r_type = 1;
            j_type = 0;
            i_type = 0;

        end
        else if (opcode == 6'b000010 || opcode == 6'b000011) begin
            r_type = 0;
            j_type = 1;
            i_type = 0;
        end
        else begin
            r_type = 0;
            j_type = 0;
            i_type = 1;
        end
    end
    else if (fetch==1)begin
         r_type = 0;
         j_type = 0;
         i_type = 0;
    end
end

//Decode field assignments
always@(*) begin
    if ((exec1 == 1)||(exec2 ==1)) begin
        if (r_type == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx = instruction[25:21]; //rs
            reg_b_idx = instruction[20:16]; //rt
            destination_reg = instruction[15:11]; //rd
            shift_amount = instruction[10:6]; //sa
            function_code = instruction[5:0];
            immediate = 0;
            memory = 0;

            //if instruction

        end
        else if (j_type == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx = 5'd0;
            reg_b_idx = 5'd0;
            shift_amount = 0;
            function_code = 6'd0;
            immediate = 32'd0;
            memory = instruction[25:0];

            if (instruction_code == JAL)
                destination_reg = 31;
            else
                destination_reg = 0;
        end

        else if (i_type == 1) begin
            //assign groups of bits of instruction word to each field.
            reg_a_idx = instruction[25:21];
            reg_b_idx = instruction[20:16];
            shift_amount = 0;
            function_code = 6'd0;
            memory = 26'd0;

            if (instruction_code == BGEZAL || instruction_code == BLTZAL) begin
                destination_reg = 31;
            end
            else begin
                destination_reg = instruction[20:16];
            end

            //Sign extension logic for immediate - Multiple formats
                if (instruction_code == ANDI || instruction_code == ORI || instruction_code == XORI)
                    immediate = {16'd0,instruction[15:0]};
                else if (instruction_code == LUI) begin
                    immediate = {instruction[15:0], 16'd0};
                end
                else
                    immediate = {{16{instruction[15]}},instruction[15:0]};
        end
    end
end

always@(*) begin //make sure reg file enables go high in the right cycle
    if (exec2) begin
        if (r_type) begin
            if (instruction_code == MTHI || instruction_code == MTLO || instruction_code == JR)
                reg_write_en = 0;
            else if (instruction_code == MULT || instruction_code == MULTU || instruction_code == DIV || instruction_code == DIVU)
                reg_write_en = 0;
            else
                reg_write_en = 1;
        end
        else if (i_type) begin
                //BGEZAL-------------------------------------------  //BLTZAL------------------------------------------   LB-------------------- LBU------------------- LH-------------------  LHU------------------  LUI------------------- LW--------------------  LWL------------------- LWR-------------------
            if ((opcode==6'b000001)&&(instruction[20:16]==5'b10001)||(opcode==6'b000001)&&(instruction[20:16]==5'b10000)||(opcode==6'b100000)||(opcode==6'b100100)||(opcode==6'b100001)||(opcode==6'b100101)||(opcode==6'b001111)||(opcode==6'b100011)||(opcode==6'b100010)||(opcode==6'b100110)) begin
                reg_write_en = 1;
            end
                //ADDI---------------  ADDIU----------------  ANDI-----------------  ORI-------------------  XORI---------------- SLTI----------------- SLTIU-------------
            else if ((opcode==6'b001000)||(opcode==6'b001001)||(opcode==6'b001100)||(opcode==6'b001101)||(opcode==6'b001110)||(opcode==6'b001010)||(opcode==6'b001011)) begin
                reg_write_en = 1;
            end
            else
                reg_write_en = 0;

        end
        else if (j_type && instruction_code == JAL)
            reg_write_en = 1;
        else
            reg_write_en = 0;
    end
    else
        reg_write_en = 0;

end

//decoding the instruction code which will replace opcode, rtype, itype and jtype outputs
always@(*) begin
    if ((opcode==6'd0)&&(function_code==6'b100000)) instruction_code = ADD;
    else if (opcode==6'b001000) instruction_code = ADDI;
    else if (opcode==6'b001001) instruction_code = ADDIU;
    else if ((opcode==6'd0)&&(function_code==6'b100001)) instruction_code = ADDU;
    else if ((opcode==6'd0)&&(function_code==6'b100100)) instruction_code = AND;
    else if (opcode==6'b001100) instruction_code = ANDI;
    else if ((opcode==6'd0)&&(function_code==6'b011010)) instruction_code = DIV;
    else if ((opcode==6'd0)&&(function_code==6'b011011)) instruction_code = DIVU;
    else if ((opcode==6'd0)&&(function_code==6'b010000)) instruction_code = MFHI;
    else if ((opcode==6'd0)&&(function_code==6'b010010)) instruction_code = MFLO;
    else if ((opcode==6'd0)&&(function_code==6'b010001)) instruction_code = MTHI;
    else if ((opcode==6'd0)&&(function_code==6'b010011)) instruction_code = MTLO;
    else if ((opcode==6'd0)&&(function_code==6'b011000)) instruction_code = MULT;
    else if ((opcode==6'd0)&&(function_code==6'b011001)) instruction_code = MULTU;
    else if ((opcode==6'd0)&&(function_code==6'b100101)) instruction_code = OR;
    else if (opcode==6'b001101) instruction_code = ORI;
    else if ((opcode==6'd0)&&(function_code==6'b000000)) instruction_code = SLL;
    else if ((opcode==6'd0)&&(function_code==6'b000100)) instruction_code = SLLV;
    else if ((opcode==6'd0)&&(function_code==6'b101010)) instruction_code = SLT;
    else if (opcode==6'b001010) instruction_code = SLTI;
    else if (opcode==6'b001011) instruction_code = SLTIU;
    else if ((opcode==6'd0)&&(function_code==6'b101011)) instruction_code = SLTU;
    else if ((opcode==6'd0)&&(function_code==6'b000011)) instruction_code = SRA;
    else if ((opcode==6'd0)&&(function_code==6'b000111)) instruction_code = SRAV;
    else if ((opcode==6'd0)&&(function_code==6'b000010)) instruction_code = SRL;
    else if ((opcode==6'd0)&&(function_code==6'b000110)) instruction_code = SRLV;
    else if ((opcode==6'd0)&&(function_code==6'b100011)) instruction_code = SUBU;
    else if ((opcode==6'd0)&&(function_code==6'b100110)) instruction_code = XOR;
    else if (opcode==6'b001110) instruction_code = XORI;

    else if (opcode==6'b000100) instruction_code = BEQ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b00001)) instruction_code = BGEZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b10001))  instruction_code = BGEZAL;
    else if (opcode==6'b000111) instruction_code = BGTZ;
    else if (opcode==6'b000110) instruction_code = BLEZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b00000)) instruction_code = BLTZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b10000)) instruction_code = BLTZAL;
    else if (opcode==6'b000101) instruction_code = BNE;
    else if (opcode==6'b000010) instruction_code = J;
    else if (opcode==6'b000011) instruction_code = JAL;
    else if ((opcode==6'd0)&&(function_code==6'b001001)) instruction_code = JALR;
    else if ((opcode==6'd0)&&(function_code==6'b001000)) instruction_code = JR;

    else if (opcode==6'b100000) instruction_code = LB;
    else if (opcode==6'b100100) instruction_code = LBU;
    else if (opcode==6'b100001)  instruction_code = LH;
    else if (opcode==6'b100101) instruction_code = LHU;
    else if (opcode==6'b001111) instruction_code = LUI;
    else if (opcode==6'b100011) instruction_code = LW;
    else if (opcode==6'b100010) instruction_code = LWL;
    else if (opcode==6'b100110) instruction_code = LWR;
    else if (opcode==6'b101000) instruction_code = SB;
    else if (opcode==6'b101001) instruction_code = SH;
    else if (opcode==6'b101011) instruction_code = SW;

end

endmodule
