//add in 7 bit instruction code 
module IR_decode( 
input logic [31:0] current_instruction, 
input logic fetch,
input logic exec_one,
input logic exec_two,

output logic r_type, //control signals that go high depending on the type of instruction  
                     // mux control signals 
output logic j_type, // “ 
output logic i_type, // ” 
output logic [4:0] shift, // only relevant to r_type instructions  
output logic [5:0] function_code, // “ - goes to the alu  
output logic [4:0] destination_reg, //register addresses 5 
output logic [4:0] register_one, // ” 
output logic [4:0] register_two, // “  
output logic [31:0] immediate, // only relevant to I_type instructions – immediate value (sign extended for ALU so 32 bits long) 
output logic [25:0] memory, // only relevant to j_type instructions – memory address 
output logic write_en, // for register files 
output logic [5:0] opcode
//output logic [6:0] instruction_code
);  

logic [31:0] saved_instruction;
logic [31:0] instruction; 

always@(*) begin 
    if (exec_one==1)begin 
        instruction = current_instruction;
        saved_instruction = current_instruction;
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


endmodule
