module IR_pipelined_tb();
    // inputs
    logic clk;
    logic[31:0] current_instruction;
    logic is_current_instruction_valid;
    logic fetch;
    logic exec1;
    logic exec2;

    // outputs
    logic[4:0] shift_amount;
    logic[4:0] destination_reg_1;
    logic[4:0] destination_reg_2;
    logic[4:0] reg_a_idx_1;
    logic[4:0] reg_a_idx_2;
    logic[4:0] reg_b_idx_1;
    logic[4:0] reg_b_idx_2;
    logic[31:0] immediate_1;
    logic[31:0] immediate_2;
    logic[25:0] memory;
    logic reg_write_en;
    logic[6:0] instruction_code_1;
    logic[6:0] instruction_code_2;
    logic memory_hazard;

    //set a clock
    initial begin
        $dumpfile("IR_pipelined_tb.vcd");
        $dumpvars(0, IR_pipelined_tb);

        clk = 0;
        repeat (1000) begin
            #1 clk = !clk;
        end
    end

    initial begin
        fetch = 1;
        exec1 = 0;
        exec2 = 0;
        current_instruction = 32'h24020010; // ADDIU $v0, $zero, 0x10
        is_current_instruction_valid = 1;

        #1;

        fetch = 0;
        exec1 = 1;
        exec2 = 0;

        #1;

        assert (instruction_code_1 == 7'd3) else $error("instruction code 1 is %b, but it should be 0000011", instruction_code_1);
        assert (reg_a_idx_1 == 0) else $error("register a idx is %b, but it should be 0", reg_a_idx_1);
        assert (immediate_1 == 32'h10) else $error("immediate 1 is %b, but it should be 0", immediate_1);
        assert (destination_reg_1 == 5'b00010) else $error("immediate 1 is %b, but it should be 0", destination_reg_1);

        #1;

        current_instruction = 32'h02111021; // ADDU $v0, $s0, $s1

        fetch = 0;
        exec1 = 0;
        exec2 = 1;

        #1;

        assert (instruction_code_1 == 7'd4) else $error("instruction code 1 is %b, but it should be 0000100", instruction_code_1);
        assert (reg_a_idx_1 == 5'b10000) else $error("register a idx 1 is %b, but it should be 10000", reg_a_idx_1);
        assert (reg_b_idx_1 == 5'b10001) else $error("register b idx 1 is %b, but it should be 10001", reg_b_idx_1);
        assert (instruction_code_2 == 7'd3) else $error("instruction code 2 is %b, but it should be 0000011", instruction_code_2);
        assert (reg_a_idx_2 == 0) else $error("register a idx is %b, but it should be 0", reg_a_idx_2);
        assert (immediate_2 == 32'h10) else $error("immediate 2 is %b, but it should be 0", immediate_2);
        assert (destination_reg_2 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_2);

        #1;

        current_instruction = 32'h02531025; // OR $v0, $s2, $s3

        fetch = 1;
        exec1 = 0;
        exec2 = 0;

        #1;

        assert (instruction_code_1 == 7'd15) else $error("instruction code 1 is %b, but it should be 0001111", instruction_code_1);
        assert (reg_a_idx_1 == 5'b10010) else $error("register a idx 1 is %b, but it should be 10010", reg_a_idx_1);
        assert (reg_b_idx_1 == 5'b10011) else $error("register b idx 1 is %b, but it should be 10011", reg_b_idx_1);
        assert (destination_reg_1 == 5'b00010) else $error("destination register 1 is %b, but it should be 00010", destination_reg_1);
        assert (instruction_code_2 == 7'd4) else $error("instruction code 2 is %b, but it should be 0000100", instruction_code_2);
        assert (reg_a_idx_2 == 5'b10000) else $error("register a idx 2 is %b, but it should be 10000", reg_a_idx_2);
        assert (reg_b_idx_2 == 5'b10001) else $error("register b idx 2 is %b, but it should be 10001", reg_b_idx_2);
        assert (destination_reg_2 == 5'b00010) else $error("destination register 2 is %b, but it should be 0000010", destination_reg_2);

        #1;

        current_instruction = 32'h02b60019; // MULTU $s5, $s6

        fetch = 0;
        exec1 = 1;
        exec2 = 0;

        #1;

        assert (instruction_code_1 == 7'd14) else $error("instruction code 1 is %b, but it should be 0001110", instruction_code_1);
        assert (reg_a_idx_1 == 5'b10101) else $error("register a idx 1 is %b, but it should be 10101", reg_a_idx_1);
        assert (reg_b_idx_1 == 5'b10110) else $error("register b idx 1 is %b, but it should be 10110", reg_b_idx_1);
        assert (instruction_code_2 == 7'd15) else $error("instruction code 2 is %b, but it should be 0001111", instruction_code_2);
        assert (reg_a_idx_2 == 5'b10010) else $error("register a idx 2 is %b, but it should be 10010", reg_a_idx_2);
        assert (reg_b_idx_2 == 5'b10011) else $error("register b idx 2 is %b, but it should be 10011", reg_b_idx_2);
        assert (destination_reg_2 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_2);

        #1;

        current_instruction = 32'h36021111; // ORI $v0, $s0, 0x1111

        fetch = 0;
        exec1 = 0;
        exec2 = 1;

        #1;

        assert (instruction_code_1 == 7'd16) else $error("instruction code 1 is %b, but it should be 0001110", instruction_code_2);
        assert (immediate_1 == 32'h1111) else $error("immediate 1 is %h, but it should be 0x00001111", immediate_1);
        assert (reg_a_idx_1 == 5'b10000) else $error("register a idx 1 is %b, but it should be 10000", reg_a_idx_1);
        assert (destination_reg_1 == 5'b00010) else $error("destination register 1 is %b, but it should be 00010", destination_reg_1);
        assert (instruction_code_2 == 7'd14) else $error("instruction code 2 is %b, but it should be 0001110", instruction_code_2);
        assert (reg_a_idx_2 == 5'b10101) else $error("register a idx 2 is %b, but it should be 10101", reg_a_idx_2);
        assert (reg_b_idx_2 == 5'b10110) else $error("register b idx 2 is %b, but it should be 10110", reg_b_idx_2);

        #1;

        current_instruction = 32'h3a02ff56; // XORI $v0, $s0, 0xff56

        fetch = 0;
        exec1 = 0;
        exec2 = 1;

        #1;

        assert (instruction_code_1 == 7'd29) else $error("instruction code 1 is %b, but it should be 0001110", instruction_code_1);
        assert (immediate_1 == 32'hff56) else $error("immediate 1 is %h, but it should be 0x00001111", immediate_1);
        assert (reg_a_idx_1 == 5'b10000) else $error("register a idx 1 is %b, but it should be 10000", reg_a_idx_1);
        assert (destination_reg_1 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_1);
        assert (instruction_code_2 == 7'd16) else $error("instruction code 2 is %b, but it should be 0001110", instruction_code_2);
        assert (immediate_2 == 32'h1111) else $error("immediate 2 is %h, but it should be 0x00001111", immediate_2);
        assert (reg_a_idx_2 == 5'b10000) else $error("register a idx 2 is %b, but it should be 10000", reg_a_idx_2);
        assert (destination_reg_2 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_2);

        #1;

        current_instruction = 32'h8e220014; // LW $v0, 0x14($s1)

        fetch = 1;
        exec1 = 0;
        exec2 = 0;

        #1;

        assert (instruction_code_1 == 7'd47) else $error("instruction code 1 is %b, but it should be 0101111", instruction_code_1);
        assert (immediate_1 == 32'h14) else $error("immediate 1 is %h, but it should be 0x0014", immediate_1);
        assert (reg_a_idx_1 == 5'b10001) else $error("register a idx 1 is %b, but it should be 10001", reg_a_idx_1);
        assert (destination_reg_1 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_1);
        assert (memory_hazard == 1) else $error("memory_hazard is %b, but it should be 1", memory_hazard);
        assert (instruction_code_2 == 7'd29) else $error("instruction code 1 is %b, but it should be 0001110", instruction_code_1);
        assert (immediate_2 == 32'hff56) else $error("immediate 1 is %h, but it should be 0x00001111", immediate_1);
        assert (reg_a_idx_2 == 5'b10000) else $error("register a idx 1 is %b, but it should be 10000", reg_a_idx_1);
        assert (destination_reg_2 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_2);

        #1;

        fetch = 0;
        exec1 = 1;
        exec2 = 0;

        #1;

        assert (instruction_code_1 == 7'd17) else $error("instruction code 1 is %b, but it should be 0", instruction_code_1); // SLL is NOP
        assert (immediate_1 == 32'h0) else $error("immediate 1 is %h, but it should be 0x0014", immediate_1);
        assert (reg_a_idx_1 == 5'b00000) else $error("register a idx 1 is %b, but it should be 00000", reg_a_idx_1);
        assert (reg_b_idx_1 == 5'b00000) else $error("register b idx 1 is %b, but it should be 00000", reg_a_idx_1);
        assert (destination_reg_1 == 5'b00000) else $error("destination register is %b, but it should be 0000010", destination_reg_1);
        assert (instruction_code_2 == 7'd47) else $error("instruction code 1 is %b, but it should be 0101111", instruction_code_2);
        assert (immediate_2 == 32'h14) else $error("immediate 1 is %h, but it should be 0x0014", immediate_2);
        assert (reg_a_idx_2 == 5'b10001) else $error("register a idx 1 is %b, but it should be 10001", reg_a_idx_2);
        assert (destination_reg_2 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_2);

        #1;

        current_instruction = 32'h3a02ff56; // XORI $v0, $s0, 0xff56

        fetch = 0;
        exec1 = 0;
        exec2 = 1;

        #1;

        assert (instruction_code_1 == 7'd29) else $error("instruction code 1 is %b, but it should be 0001110", instruction_code_1);
        assert (immediate_1 == 32'hff56) else $error("immediate 1 is %h, but it should be 0x00001111", immediate_1);
        assert (reg_a_idx_1 == 5'b10000) else $error("register a idx 1 is %b, but it should be 10000", reg_a_idx_1);
        assert (destination_reg_1 == 5'b00010) else $error("destination register is %b, but it should be 0000010", destination_reg_1);
        assert (instruction_code_2 == 7'd17) else $error("instruction code 1 is %b, but it should be 0", instruction_code_1); // SLL is NOP
        assert (immediate_2 == 32'h0) else $error("immediate 1 is %h, but it should be 0x0014", immediate_1);
        assert (reg_a_idx_2 == 5'b00000) else $error("register a idx 1 is %b, but it should be 00000", reg_a_idx_1);
        assert (reg_b_idx_2 == 5'b00000) else $error("register b idx 1 is %b, but it should be 00000", reg_a_idx_1);
        assert (destination_reg_2 == 5'b00000) else $error("destination register is %b, but it should be 0000010", destination_reg_1);

        $display("Test finished!");
        $finish();
    end


    IR_decode dut(
        .clk(clk), .is_current_instruction_valid(is_current_instruction_valid), .current_instruction(current_instruction), .fetch(fetch), .exec1(exec1), .exec2(exec2),
        .shift_amount(shift_amount), .destination_reg_1(destination_reg_1), .destination_reg_2(destination_reg_2), .reg_a_idx_1(reg_a_idx_1), .reg_a_idx_2(reg_a_idx_2),
        .reg_b_idx_1(reg_b_idx_1), .reg_b_idx_2(reg_b_idx_2), .immediate_1(immediate_1), .immediate_2(immediate_2), .memory(memory),
        .reg_write_en(reg_write_en), .instruction_code_1(instruction_code_1), .instruction_code_2(instruction_code_2), .memory_hazard(memory_hazard)
    );

endmodule