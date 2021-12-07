module IR_tb (); 
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

// Note that with testbenches that include fetch, instruction will be that of the previous instruction but all enables will go to 0 (i.e. rtype, itype, jtype and write_en)
// Note that instruction with exce2 high will have stored the instrcution and will not read new instruction 
initial begin 
    //test case 1 - testing an R-Type instruction is HIGH in EXEC1 - SUCCESS
    instruction = 32'b00000010101011101010001010100000; //r_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'b01010)
    assert (destination_reg == 5'b10100)
    assert (register_one == 5'b10101)
    assert (register_two == 5'b01110)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 1)
    assert (instruction_code == 7'd1)
    $display("TESTCASE 1: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 1 - SUCCESS");
   
    //test case 1.1 - testing an R-Type instruction with a low write_en - i.e JR is LOW in EXEC1 - SUCCESS
    instruction = 32'b00000000001000000000000000001000; //r_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 0)
    assert (instruction_code == 7'd41)
    $display ("TESTCASE 1.1: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 1.1 - SUCCESS");
   
    //test case 1.2 - R-Type is LOW in EXEC2 - SUCCESS
    instruction = 32'b00000000001000000000000000001000; //r_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 0)
    assert (instruction_code == 7'd41)

    $display("TESTCASE 1.2: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);

    //test case 1.3, 1.4 setup
    instruction = 32'b00000010101011101010001010001001; //r_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;
    #1
   
    //test case 1.3 - JALR is HIGH in EXEC1 - SUCCESS
    instruction = 32'b00000010101011101010001010001001; //r_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'b01010)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b10101)
    assert (register_two == 5'b01110)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 1)
    assert (instruction_code == 7'd40)

    $display("TESTCASE 1.3: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 1.3 - SUCCESS");

    //test case 1.4 - JALR is HIGH in EXEC2 - SUCCESS
    instruction = 32'b00000010101011101010001010001001; //r_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'b01010)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b10101)
    assert (register_two == 5'b01110)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 1)
    assert (instruction_code == 7'd40)

    $display("TESTCASE 1.4: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 1.4 - SUCCESS");
  
    //test case 1.5 - LOW in FETCH?
    instruction = 32'b00000010101011101010001010001001; //r_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;
    #1
    assert (shift == 5'b01010)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b10101)
    assert (register_two == 5'b01110)
    assert (memory == 0)
    assert (immediate == 0)
    assert (write_en == 0)
    assert (instruction_code == 7'd40)

    $display("TESTCASE 1.5: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 1.5 - SUCCESS");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

    ///testing the sign extend 
    //test case 2.0 - Testing an I-type instruction and sign extend immediate by 0's
    instruction = 32'b00101000101011100110000010000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b01110)
    assert (register_one == 5'b00101)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b00000000000000000110000010000000) //sign extend by 0
    assert (write_en == 1)
    assert (instruction_code == 7'd20)

    $display("TESTCASE 2.0: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.0 - SUCCESS");

    //test case 2.0.1 - Testing an I-type instruction and sign extend immediate by 1's
    instruction = 32'b00101000101011101110000010000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b01110)
    assert (register_one == 5'b00101)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111110000010000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd20)

    $display("TESTCASE 2.0.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.0.1 - SUCCESS");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

    //testing opcodes where write enables should never go high
    //test case 2.1 - Testing an I-type instruction and write enables is low for BEQ in EXEC 1 and 2 
    instruction = 32'b00010000001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd30)

    $display("TESTCASE 2.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1 - SUCCESS");

    //test case 2.1.0 - Testing an I-type instruction and write enables is low for BEQ in EXEC 1 and 2 
    instruction = 32'b00010000001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd30)

    $display("TESTCASE 2.1.0: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.0 - SUCCESS");

    //test case 2.1.2 - Testing an I-type instruction and write enables is low for BGEZ in EXEC 1 and 2 -FAILED
    instruction = 32'b00000100001000011000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00001)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd31)
    
    $display("TESTCASE 2.1.2: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.2 - SUCCESS");

    //test case 2.1.3 - Testing an I-type instruction and write enables is low for BGEZ in EXEC 1 and 2 - FAILED
    instruction = 32'b00000100001000011000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00001)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd31)

    $display("TESTCASE 2.1.3: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.3 - SUCCESS");

    
    //test case 2.1.4 - Testing an I-type instruction and write enables is low for BGTZ
    instruction = 32'b00011100001000001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1    
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd33)

    $display("TESTCASE 2.1,4: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.4 - SUCCESS");

    //set up for test case 2.1.5
    instruction = 32'b00011000001000001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    //test case 2.1.5 - Testing an I-type instruction and write enables is low for BLEZ
    instruction = 32'b00011000001000001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd34)

    $display("TESTCASE 2.1.5 ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.5 - SUCCESS");

    //test case 2.1.6 - Testing an I-type instruction and write enables is low for BLTZ
    instruction = 32'b00000100001000001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd35)

    $display("TESTCASE 2.1.6: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.6 - SUCCESS");

    //set up for 2.1.7
    instruction = 32'b00010100001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1

    //test case 2.1.7 - Testing an I-type instruction and write enables is low for BNE 
    instruction = 32'b00010100001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd37)

    $display("TESTCASE 2.1.7: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.7 - SUCCESS");

    //test case 2.1.8 - Testing SB is never high 
    instruction = 32'b10100000001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd50)

    $display("TESTCASE 2.1.8: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.8 - SUCCESS");
    
    //test case 2.1.8.1 - Testing SB is never high 
    instruction = 32'b10100000001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd50)

    $display("TESTCASE 2.1.8.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.8.1 - SUCCESS");

    //test case 2.1.9 - Testing SW is never high
    instruction = 32'b10101100001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd52)

    $display("TESTCASE 2.1.9: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.9 - SUCCESS");

    //test case 2.1.9.1 - Testing SW is never high
    instruction = 32'b10101100001000101000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b00010)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd52)
    
    $display("TESTCASE 2.1.9.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.1.9.1 - SUCCESS");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

    //testing opcodes where write enables should only go high in EXEC2
    //set up for 2.2
    instruction = 32'b00000100001100011000000000000000 ; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    //test case 2.2 - Testing an I-type instruction and write enables is high for BGEZAL in EXEC 2 and low in EXEC 1 
    instruction = 32'b00000100001100011000000000000000 ; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd32)

    $display("TESTCASE 2.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2 - SUCCESS");

    //test case 2.2.1 - Testing an I-type instruction and write enables is high for BGEZAL in EXEC 2 and low in EXEC 1 
    instruction = 32'b00000100001100011000000000000000 ; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd32)

    $display("TESTCASE 2.2.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.1 - SUCCESS");

    //set up for 2.2.2
    instruction = 32'b00000100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    //test case 2.2.2 - Testing an I-type instruction and write enables is high for BLTZAL in EXEC2 but low in EXEC1
    instruction = 32'b00000100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd36)

    $display("TESTCASE 2.2.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.2 - SUCCESS");

    //test case 2.2.3 - Testing an I-type instruction and write enables is high for BLTZAL in EXEC2 but low in EXEC1
    instruction = 32'b00000100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd36)

    $display("TESTCASE 2.2.3: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.3 - SUCCESS");

    //test case 2.2.4 - Testing write enable for LB is high in EXEC2 and not in EXEC1
    instruction = 32'b10000000001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd42)

    $display("TESTCASE 2.2.4: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.4 - SUCCESS");
    
    //testcase 2.2.4.1 - Testing write enable for LB
    instruction = 32'b10000000001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd42)

    $display("TESTCASE 2.2.4.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.4.1 - SUCCESS");
   
    //test case 2.2.5 - Testing write enable for LUI is high in EXEC2 and not in EXEC1
    instruction = 32'b00111100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd46)

    $display("TESTCASE 2.2.5: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.5 - SUCCESS");
    
    //testcase 2.2.5.1 - Testing write enable for LUI
    instruction = 32'b00111100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd46)

    $display("TESTCASE 2.2.5.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.2.5.1 - SUCCESS");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

    //testing opcodes where write enables should only go high in EXEC1
    //test case 2.3.1 - Testing write enable for ADDI is only high in EXEC 1 and not in EXEC2
    instruction = 32'b00100000001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd2)

    $display("TESTCASE 2.3.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.3.1 - SUCCESS");
    
    //testcase 2.3.1.1 - Testing write enable for ADDI
    instruction = 32'b00100000001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd2)

    $display("TESTCASE 2.3.1.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.3.1.1 - SUCCESS");

    //test case 2.3.2 - Testing write enable for SLTIU is only high in EXEC 1 and not in EXEC2 
    instruction = 32'b00101100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 1)
    assert (instruction_code == 7'd21)

    $display("TESTCASE 2.3.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.3.2 - SUCCESS");
    
    //testcase 2.3.2.1 - Testing write enable for SLTIU
    instruction = 32'b00101100001100001000000000000000; //i_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd21)

    $display("TESTCASE 2.3.2.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.3.2.1 - SUCCESS");   

    //testcase 2.4 - LOW in FETCH 
    instruction = 32'b00101100001100001000000000000000; //i_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'b10000)
    assert (register_one == 5'b00001)
    assert (register_two == 5'd0)
    assert (memory == 26'd0)
    assert (immediate == 32'b11111111111111111000000000000000) // sign extend by 1 
    assert (write_en == 0)
    assert (instruction_code == 7'd21)   

    $display("TESTCASE 2.4: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 2.4 - SUCCESS");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

    //set up for 3
    instruction = 32'b00001110101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1

    //test case 3 - Testing a J-type instruction and write enable is high for JAL in EXEC2 - SUCCESS
    instruction = 32'b00001110101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (write_en == 1)
    assert (instruction_code == 7'd39)   

    $display("TESTCASE 3: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 3 - SUCCESS");

    //set up for 3.1 
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1

    //test case 3.1 - Testing a J-type instruction and write enable is low for J in EXEC2 - SUCCESS
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (write_en == 0)
    assert (instruction_code == 7'd38)   

    $display("TESTCASE 3.1: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 3.1 - SUCCESS");

    //test case 3.2 - Testing a J-type instruction and write enable is LOW for JAL in EXEC1 - SUCCESS
    instruction = 32'b00001110101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd31)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (write_en == 0)
    assert (instruction_code == 7'd39)   

    $display("TESTCASE 3.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 3.2 - SUCCESS");

    //test case 3.3 - Testing a J-type instruction and write enable is LOW for J in EXEC1 - SUCCESS
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (write_en == 0)
    assert (instruction_code == 7'd38)   

    $display("TESTCASE 3.3: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 3.3 - SUCCESS");

    //test case 3.4 - LOW in FETCH 
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;
    #1
    assert (shift == 5'd0)
    assert (destination_reg == 5'd0)
    assert (register_one == 5'd0)
    assert (register_two == 5'd0)
    assert (memory == 26'b10101110111110011000001100)
    assert (immediate == 32'd0)
    assert (write_en == 0)
    assert (instruction_code == 7'd38)   

    $display("TESTCASE 3.4: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    $display ("TESTCASE 3.4 - SUCCESS");

    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
    
    //test case 4 - Testing FETCH, EXEC 1, EXEC 2
    //fetch
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;    
    #1
    $display("TESTCASE fetch: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    
    //exec1
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    $display("TESTCASE exec1: ", "instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
   
    //exec2
    instruction = 32'b00001010101110111110011000001100; //j_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    $display("TESTCASE exec2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    //fetch
    instruction = 32'b00000000001000000000000000001000; //r_type
    fetch = 1;
    exec_one = 0;
    exec_two = 0;    
    #1
    $display("TESTCASE fetch.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    //exec1
    instruction = 32'b00000000001000000000000000001000; //r_type
    fetch = 0;
    exec_one = 1;
    exec_two = 0;
    #1
    $display("TESTCASE exec1.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
    
    //exec2
    instruction = 32'b00000000001000001111000000001000; //r_type
    fetch = 0;
    exec_one = 0;
    exec_two = 1;
    #1
    $display("TESTCASE exec2.2: ","instruction_code:", instruction_code, ", shift = ", shift, ", destination_reg = ", destination_reg, ", register_two = ", register_two, ", register_one = ", register_one, ", memory = ", memory, ", immediate = ", immediate, " write_en = ", write_en);
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