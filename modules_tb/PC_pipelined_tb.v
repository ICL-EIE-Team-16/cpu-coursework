module PC_pipelined_tb();
    // inputs
    logic clk;
    logic reset;
    logic fetch;
    logic exec1;
    logic exec2;
    logic[6:0] instruction_code; // instruction code of instruction in EXEC1
    logic[15:0] offset;
    logic[25:0] instr_index;
    logic[31:0] register_data;
    logic zero, positive, negative;
    logic memory_hazard;

    // outputs
    logic[31:0] address;
    logic pc_halt;

    //set a clock
    initial begin
        $dumpfile("PC_pipelined_tb.vcd");
        $dumpvars(0, PC_pipelined_tb);

        clk = 0;
        repeat (1000) begin
            #1 clk = !clk;
        end
    end

    initial begin
        #2;

        reset = 1;

        #2;

        reset = 0;
        assert(address == 32'hBFC00000) else $error("address is %h but it should be: 0xBFC00000", address);

        #2;

        assert(address == 32'hBFC00004) else $error("address is %h but it should be: 0xBFC00004", address);

        #2;

        assert(address == 32'hBFC00008) else $error("address is %h but it should be: 0xBFC00008", address);

        #2;

        assert(address == 32'hBFC0000C) else $error("address is %h but it should be: 0xBFC0000C", address);

        #2;

        assert(address == 32'hBFC00010) else $error("address is %h but it should be: 0xBFC00010", address);

        #2;

        assert(address == 32'hBFC00014) else $error("address is %h but it should be: 0xBFC00014", address);

        memory_hazard = 1;

        #2;

        memory_hazard = 0;
        assert(address == 32'hBFC00014) else $error("address is %h but it should be: 0xBFC00014", address);

        #2;

        assert(address == 32'hBFC00018) else $error("address is %h but it should be: 0xBFC00018", address);

        #2;

        assert(address == 32'hBFC0001C) else $error("address is %h but it should be: 0xBFC0001C", address);

        $display("Test finished!");
        $finish();
    end

    PC dut(
        .clk(clk), .reset(reset), .fetch(fetch), .exec1(exec1), .exec2(exec2), .instruction_code(instruction_code), .offset(offset), .instr_index(instr_index),
        .register_data(register_data), .zero(zero), .positive(positive), .negative(negative), .memory_hazard(memory_hazard), .address(address), .pc_halt(pc_halt)
    );

    statemachine statemachine(
        .clk(clk), .reset(reset), .halt(pc_halt), .fetch(fetch), .exec1(exec1), .exec2(exec2)
    );
endmodule