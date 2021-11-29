module IR_decode( 

input logic [31:0] instruction, 
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
);  

assign opcode = instruction[31:26];

always@(*) begin 
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

always@(*) begin 
    if (r_type == 1) begin
        //assign groups of bits of instruction word to each field. 
        register_one = instruction[25:21];
        register_two = instruction[20:16];
        destination_reg = instruction[15:11];
        shift = instruction[10:6];
        function_code = instruction[5:0];
        immediate = 32'd0;
        memory = 26'd0;
       
       //determing write enables
        if ((r_type==1)&&(function_code!=6'b001000)) begin  // high for all r_type instrcutions but low for JR
            write_en = 1;     
        end
        else begin 
        write_en = 0; 
        end
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
             
       //determing write enables
        if((j_type==1)&&(opcode!=6'b000011)) begin // low for all j_type instructions but high for JAL
            write_en = 0;
        end 
        else begin 
            write_en = 1;
        end 
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

        //determing write enables
                          //BEQ--------------    BGEZ-------------------------------------------   BGTZ--------------   BLEZ-----------        BLTZ------------------------------------------    BNE-----------------      
        if ((i_type==1)&&(opcode!=6'b000100)&&((opcode!=6'b000001)&&(destination_reg!=5'b00001))&&(opcode!=6'b000111)&&(opcode!=6'b000110)&&((opcode!=6'b000001)&&(destination_reg!=5'b00000))&&(opcode!=6'b000101))begin
            write_en = 1; 
        end 
         else begin 
            write_en = 0;
        end
        if(((opcode==6'b000001)&&(instruction[20:16]==5'b10001))||(opcode==6'b000001)&&(instruction[20:16]==5'b10000))begin 
            write_en = 1;
        end 
       
    end
end 

endmodule
