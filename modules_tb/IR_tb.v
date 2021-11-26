module IR_tb (); // test more robustly?? how??
logic [31:0] instruction;
logic r_type; //control signals that go high depending on the type of instruction  
                     // mux control signals 
logic j_type; // "
logic i_type; // ” 
logic [4:0] shift; // only relevant to r_type instructions  
logic [5:0] function_code; // “ - goes to the alu  
logic [4:0] destination_reg; //register addresses 5 
logic [4:0] register_one; // ” 
logic [4:0] register_two; // “  
logic [31:0] immediate; // only relevant to I_type instructions – immediate value (sign extended for ALU) 
logic [25:0] memory; // only relevant to j_type instructions – memory address 
logic [5:0] opcode;
logic write_en;

initial begin 
    //test case 1 
    instruction = 32'b00000010101011101010001010110000; //r_type
    #1
    assert (r_type == 1)
    assert (j_type == 0)
    assert (i_type == 0)
    assert (function_code == 6'b110000)
    assert (shift == 5'b01010)
    assert (destination_reg == 5'b10100)
    assert (register_one == 5'b10101)
    assert (register_two == 5'b01110)
    assert (memory == 0)
    assert (immediate == 0)
    assert (opcode == 6'b000000)
    assert (write_en == 1)
    $display("opcode:",opcode,", r_type = ", r_type,", j_type = ", j_type, ", i_type = ", i_type, ", function_code = ", function_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, "write_en = ", write_en);

    //test case 2 
    instruction = 32'b01001100101011100110000010000000; //i_type
    #1
    assert (r_type == 0)
    assert (j_type == 0)
    assert (i_type == 1)
    assert (function_code == 6'd0)
    assert (shift == 5'd0)
    assert (destination_reg == 5'b01110)
    assert (register_one == 5'b00101)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b00000000000000000110000010000000) //sign extend by 0
    assert (opcode == 6'b010011)
    assert (write_en == 1)
    $display("opcode:",opcode,", r_type = ", r_type,", j_type = ", j_type, ", i_type = ", i_type, ", function_code = ", function_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, "write_en = ", write_en);

    //test case 3 
    instruction = 32'b01001100101011101110000010000000; //i_type
    #1
    assert (r_type == 0)
    assert (j_type == 0)
    assert (i_type == 1)
    assert (function_code == 6'd0)
    assert (shift == 5'd0)
    assert (destination_reg == 5'b01110)
    assert (register_one == 5'b00101)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111110000010000000) // sign extend by 1 
    assert (opcode == 6'b010011)
    assert (write_en == 1)
    $display("opcode:",opcode,", r_type = ", r_type,", j_type = ", j_type, ", i_type = ", i_type, ", function_code = ", function_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, "write_en = ", write_en);
   
    //test case 4
    instruction = 32'b00001110101110111110011000001100; //j_type
    #1
    assert (r_type == 0)
    assert (j_type == 1)
    assert (i_type == 0)
    assert (function_code == 6'd0)
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (opcode == 6'b000011) //JAL
    assert (write_en == 1)
    $display("opcode:",opcode,", r_type = ", r_type,", j_type = ", j_type, ", i_type = ", i_type, ", function_code = ", function_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, "write_en = ", write_en);

end 

IR_decode dut(
    .instruction(instruction),
    .r_type(r_type),
    .j_type(j_type),
    .i_type(i_type),
    .shift(shift),
    .destination_reg(destination_reg),
    .register_one(register_one),
    .register_two(register_two),
    .function_code(function_code),
    .memory(memory),
    .immediate(immediate),
    .opcode(opcode),
    .write_en(write_en)
    );

endmodule 