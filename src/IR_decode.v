//add in 7 bit instruction code 
module IR_decode( 
input logic [31:0] current_instruction, 
input logic fetch,
input logic exec_one,
input logic exec_two,

output logic [4:0] shift, // only relevant to r_type instructions  
output logic [4:0] destination_reg, //register addresses 5 
output logic [4:0] register_one, // ” 
output logic [4:0] register_two, // “  
output logic [31:0] immediate, // only relevant to I_type instructions – immediate value (sign extended for ALU so 32 bits long) 
output logic [25:0] memory, // only relevant to j_type instructions – memory address 
output logic write_en, // for register files 
output logic [6:0] instruction_code

);  

logic r_type;
logic j_type;
logic i_type;
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

} code_def;

always@(*) begin 
    if (exec_one==1)begin 
        instruction = current_instruction;
        saved_instruction <= current_instruction;
    end 
    else if (exec_two == 1) begin 
        instruction = saved_instruction;
    end 
end
 
always@(*) begin 
    if ((exec_one == 1)||(exec_two==1)) begin
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

always@(*) begin 
    if ((exec_one == 1)||(exec_two ==1)) begin
        if (r_type == 1) begin
            //assign groups of bits of instruction word to each field. 
            register_one = instruction[25:21];
            register_two = instruction[20:16];
            destination_reg = instruction[15:11];
            shift = instruction[10:6];
            function_code = instruction[5:0];
            immediate = 32'd0;
            memory = 26'd0;
        
        end 
        else if (j_type == 1) begin
            //assign groups of bits of instruction word to each field. 
            register_one = 5'd0;
            register_two = 5'd0;
            destination_reg = 5'd0;
            shift = 0;
            function_code = 6'd0;
            immediate = 32'd0;
            memory = instruction[25:0];
        end 
        else if (i_type == 1) begin
            //assign groups of bits of instruction word to each field.
            register_one = instruction[25:21];
            register_two = 5'd0;
            destination_reg = instruction[20:16];
            shift = 0;
            function_code = 6'd0;
            memory = 26'd0;
            
            //sign extend the immediate to 32 bits. - however do we need sign extended instructions for branch instructions 
            if (instruction[15] == 0) begin 
                immediate = {16'd0,instruction[15:0]};
            end 
            else if (instruction [15] == 1) begin
                immediate = {16'd65535,instruction[15:0]};
            end       
        end
    end 
end 

always@(*) begin //make sure enables go high in the right cycle 
    if (fetch == 0) begin 
        // determining write enables - R Type
        if ((exec_one == 1)&&(exec_two == 0)&&(fetch==0)) begin // high for all r_type instrcutions but low for JR in EXEC1
            if ((r_type==1)&&(function_code!=6'b001000)) begin  
                write_en = 1;     
            end
        
            else if ((r_type==1)&&(function_code==6'b001000)) begin 
                write_en = 0; 
            end
        end 

        else if ((exec_one == 0)&&(exec_two == 1)&&(fetch==0)) begin // LOW for all r_type instrcutions but HIGH for JALR in EXEC2
            if ((r_type==1)&&(function_code==6'b001001)) begin 
                write_en =1;
            end 
            else if ((r_type==1)&&(function_code!=6'b001001))begin 
                write_en=0;
            end 
        end

        //determining write enables - I Type 
                                        //ADDI---------------  ADDIU----------------  ANDI-----------------  ORI-------------------  XORI---------------- SLTI----------------- SLTIU-------------
        if ((exec_one==1)&&(i_type==1)&&((opcode==6'b001000)||(opcode==6'b001001)||(opcode==6'b001100)||(opcode==6'b001101)||(opcode==6'b001110)||(opcode==6'b001010)||(opcode==6'b001011))) begin
            write_en = 1;
        end
        else if ((exec_one==1)&&(i_type==1)&&((opcode!=6'b001000)||(opcode!=6'b001001)||(opcode!=6'b001100)||(opcode!=6'b001101)||(opcode!=6'b001110)||(opcode!=6'b001010)||(opcode!=6'b001011))) begin
            write_en = 0;
        end                             //BGEZAL-------------------------------------------  //BLTZAL------------------------------------------   LB-------------------- LBU------------------- LH-------------------  LHU------------------  LUI------------------- LW--------------------  LWL------------------- LWR-------------------
        if ((exec_two==1)&&(i_type==1)&&((opcode==6'b000001)&&(instruction[20:16]==5'b10001)||(opcode==6'b000001)&&(instruction[20:16]==5'b10000)||(opcode==6'b100000)||(opcode==6'b100100)||(opcode==6'b100001)||(opcode==6'b100101)||(opcode==6'b001111)||(opcode==6'b100011)||(opcode==6'b100010)||(opcode==6'b100110))) begin
            write_en = 1;
        end
        else if ((exec_two==1)&&(i_type==1)&&((opcode!=6'b000001)&&(instruction[20:16]!=5'b10001)||(opcode!=6'b000001)&&(instruction[20:16]!=5'b10000)||(opcode != 6'b100000)||(opcode != 6'b100100)||(opcode != 6'b100001)||(opcode != 6'b100101)||(opcode != 6'b001111)||(opcode != 6'b100011)||(opcode != 6'b100010)||(opcode != 6'b100110))) begin
            write_en = 0;
        end


        // determining write enables - J Type
            if((exec_two==1)&&(j_type==1)&&(opcode!=6'b000011)) begin // low for all j_type instructions but high for JAL only in EXEC2
                write_en = 0;
            end 
            else if ((exec_two==1)&&(j_type==1)&&(opcode==6'b000011))begin 
                write_en = 1;        
            end 
    end 

    else if (fetch == 1) begin 
        write_en = 0;
    end 

end

//decoding the instruction code which will replace opcode, rtype, itype and jtype outputs 
always@(*) begin 
    if ((opcode==6'd0)&&(function_code==6'b100000)) instruction_code <= ADD;
    else if (opcode==6'b001000) instruction_code <= ADDI;
    else if (opcode==6'b001001) instruction_code <= ADDIU;
    else if ((opcode==6'd0)&&(function_code==6'b100001)) instruction_code <= ADDU;
    else if ((opcode==6'd0)&&(function_code==6'b100100)) instruction_code <= AND;
    else if (opcode==6'b001100) instruction_code <= ANDI;
    else if ((opcode==6'd0)&&(function_code==6'b011010)) instruction_code <= DIV;
    else if ((opcode==6'd0)&&(function_code==6'b011011)) instruction_code <= DIVU;
    else if ((opcode==6'd0)&&(function_code==6'b010000)) instruction_code <= MFHI;
    else if ((opcode==6'd0)&&(function_code==6'b010010)) instruction_code <= MFLO;
    else if ((opcode==6'd0)&&(function_code==6'b010001)) instruction_code <= MTHI;
    else if ((opcode==6'd0)&&(function_code==6'b010011)) instruction_code <= MTLO;
    else if ((opcode==6'd0)&&(function_code==6'b011000)) instruction_code <= MULT;
    else if ((opcode==6'd0)&&(function_code==6'b011001)) instruction_code <= MULTU;
    else if ((opcode==6'd0)&&(function_code==6'b100101)) instruction_code <= OR;
    else if (opcode==6'b001101) instruction_code <= ORI;
    else if ((opcode==6'd0)&&(function_code==6'b000000)) instruction_code <= SLL;
    else if ((opcode==6'd0)&&(function_code==6'b000100)) instruction_code <= SLLV;
    else if ((opcode==6'd0)&&(function_code==6'b101010)) instruction_code <= SLT;
    else if (opcode==6'b001010) instruction_code <= SLTI;
    else if (opcode==6'b001011) instruction_code <= SLTIU;
    else if ((opcode==6'd0)&&(function_code==6'b101011)) instruction_code <= SLTU;
    else if ((opcode==6'd0)&&(function_code==6'b000011)) instruction_code <= SRA;
    else if ((opcode==6'd0)&&(function_code==6'b000111)) instruction_code <= SRAV;
    else if ((opcode==6'd0)&&(function_code==6'b000010)) instruction_code <= SRL;
    else if ((opcode==6'd0)&&(function_code==6'b000110)) instruction_code <= SRLV;
    else if ((opcode==6'd0)&&(function_code==6'b100011)) instruction_code <= SUBU;
    else if ((opcode==6'd0)&&(function_code==6'b100110)) instruction_code <= XOR;
    else if (opcode==6'b001110) instruction_code <= XORI;
    
    else if (opcode==6'b000100) instruction_code <= BEQ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b00001)) instruction_code <= BGEZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b10001))  instruction_code <= BGEZAL;
    else if (opcode==6'b000111) instruction_code <= BGTZ;
    else if (opcode==6'b000110) instruction_code <= BLEZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b00000)) instruction_code <= BLTZ;
    else if ((opcode==6'b000001)&&(instruction[20:16]==5'b10000)) instruction_code <= BLTZAL;
    else if (opcode==6'b000101) instruction_code <= BNE;
    else if (opcode==6'b000010) instruction_code <= J;
    else if (opcode==6'b000011) instruction_code <= JAL;
    else if ((opcode==6'd0)&&(function_code==6'b001001)) instruction_code <= JALR;
    else if ((opcode==6'd0)&&(function_code==6'b001000)) instruction_code <= JR;
    
    else if (opcode==6'b100000) instruction_code <= LB;
    else if (opcode==6'b100100) instruction_code <= LBU;
    else if (opcode==6'b100001)  instruction_code <= LH;
    else if (opcode==6'b100101) instruction_code <= LHU;
    else if (opcode==6'b001111) instruction_code <= LUI;
    else if (opcode==6'b100011) instruction_code <= LW;
    else if (opcode==6'b100010) instruction_code <= LWL;
    else if (opcode==6'b100110) instruction_code <= LWR;
    else if (opcode==6'b101000) instruction_code <= SB;
    else if (opcode==6'b101001) instruction_code <= SH;
    else if (opcode==6'b101011) instruction_code <= SW;

end 

endmodule
