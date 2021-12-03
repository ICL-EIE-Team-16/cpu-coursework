module instruction_code_tb();
logic [31:0] instruction;
logic [4:0] shift; // only relevant to r_type instructions  
logic [4:0] destination_reg; //register addresses 5 
logic [4:0] register_one; // ” 
logic [4:0] register_two; // “  
logic [31:0] immediate; // only relevant to I_type instructions – immediate value (sign extended for ALU) 
logic [25:0] memory; // only relevant to j_type instructions – memory address 
logic fetch;
logic exec_one;
logic exec_two;
logic write_en;
logic [6:0] instruction_code;

initial begin 
    //Test Case 1
    instruction = 32'b00000000000000000000000000100000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd1)
    $display("TESTCASE 1: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 1 - SUCCESS");

    //Test Case 2
    instruction = 32'b00100000000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd2)
    $display("TESTCASE 2: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 2 - SUCCESS");

    //Test Case 3
    instruction = 32'b00100100000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd3)
    $display("TESTCASE 3: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 3 - SUCCESS");

    //Test Case 4
    instruction = 32'b00000000000000000000000000100001; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd4)
    $display("TESTCASE 4: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 4 - SUCCESS");

    //Test Case 5
    instruction = 32'b00000000000000000000000000100100; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd5)
    $display("TESTCASE 5: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 5 - SUCCESS");

    //Test Case 6
    instruction = 32'b00110000000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd6)
    $display("TESTCASE 6: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 6 - SUCCESS");

    //Test Case 7
    instruction = 32'b00000000000000000000000000011010; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd7)
    $display("TESTCASE 7: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 7 - SUCCESS");

    //Test Case 8
    instruction = 32'b00000000000000000000000000011011; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd8)
    $display("TESTCASE 8: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 8 - SUCCESS");

    //Test Case 9
    instruction = 32'b00000000000000000000000000010000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd9)
    $display("TESTCASE 9: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 9 - SUCCESS");

    //Test Case 10
    instruction = 32'b00000000000000000000000000010010; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd10)
    $display("TESTCASE 10: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 10 - SUCCESS");

    //Test Case 11
    instruction = 32'b00000000000000000000000000010001; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd11)
    $display("TESTCASE 11: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 11 - SUCCESS");

    //Test Case 12
    instruction = 32'b00000000000000000000000000010011; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd12)
    $display("TESTCASE 12: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 12 - SUCCESS");

    //Test Case 13
    instruction = 32'b00000000000000000000000000011000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd13)
    $display("TESTCASE 13: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 13 - SUCCESS");

    //Test Case 14
    instruction = 32'b00000000000000000000000000011001; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd14)
    $display("TESTCASE 14: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 14 - SUCCESS");


    //Test Case 15
    instruction = 32'b00000000000000000000000000100101; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd15)
    $display("TESTCASE 15: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 15 - SUCCESS");

    //Test Case 16
    instruction = 32'b00110100000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd16)
    $display("TESTCASE 16: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 16 - SUCCESS");

    //Test Case 17
    instruction = 32'b00000000000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd17)
    $display("TESTCASE 17: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 17 - SUCCESS");

    //Test Case 18
    instruction = 32'b00000000000000000000000000000100; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd18)
    $display("TESTCASE 18: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 18 - SUCCESS");

    //Test Case 19
    instruction = 32'b00000000000000000000000000101010; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd19)
    $display("TESTCASE 19: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 19 - SUCCESS");

    //Test Case 20
    instruction = 32'b00101000000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd20)
    $display("TESTCASE 20: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 20 - SUCCESS");

    //Test Case 21
    instruction = 32'b00101100000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd21)
    $display("TESTCASE 21: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 21 - SUCCESS");

    //Test Case 22
    instruction = 32'b00000000000000000000000000101011; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd22)
    $display("TESTCASE 22: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 22 - SUCCESS");

    //Test Case 23
    instruction = 32'b00000000000000000000000000000011; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd23)
    $display("TESTCASE 23: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 23 - SUCCESS");

    //Test Case 24
    instruction = 32'b00000000000000000000000000000111; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd24)
    $display("TESTCASE 24: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 24 - SUCCESS");

    //Test Case 25
    instruction = 32'b00000000000000000000000000000010; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd25)
    $display("TESTCASE 25: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 25 - SUCCESS");

     //Test Case 26 
    instruction = 32'b00000000000000000000000000000110; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd26)
    $display("TESTCASE 26: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 26 - SUCCESS");

     //Test Case 27
    instruction = 32'b00000000000000000000000000100011; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd27)
    $display("TESTCASE 27: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 27 - SUCCESS");

     //Test Case 28
    instruction = 32'b00000000000000000000000000100110; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd28)
    $display("TESTCASE 28: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 28 - SUCCESS");

     //Test Case 29
    instruction = 32'b00000000000000000000000000001110; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd29)
    $display("TESTCASE 29: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 29 - SUCCESS");

     //Test Case 30
    instruction = 32'b00010000000000000000000000000000; 
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (instruction_code == 7'd30)
    $display("TESTCASE 30: ", "instruction_code:", instruction_code);
    $display ("TESTCASE 30 - SUCCESS");


end

IR_decode dut(
    .current_instruction(instruction),
    .shift(shift),
    .destination_reg(destination_reg),
    .register_one(register_one),
    .register_two(register_two),
    .memory(memory),
    .immediate(immediate),
    .write_en(write_en),
    .fetch(fetch),
    .exec_one(exec_one),
    .exec_two(exec_two),
    .instruction_code(instruction_code)
    );

endmodule 