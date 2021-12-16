module hazard_detector_tb();
    // inputs
    logic clk;
    logic[6:0] instr_code;

    // output
    logic hazard;

    //set a clock
    initial begin
        $dumpfile("hazard_detector.vcd");
        $dumpvars(0, hazard_detector_tb);

        clk = 0;
        repeat (1000) begin
            #1 clk = !clk;
        end
    end

    initial begin
        instr_code = 7'd1; // ADD
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        instr_code = 7'd6; // ANDI
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        instr_code = 7'd21; // SLTIU
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        instr_code = 7'd27; // SUBU
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        instr_code = 7'd32; // BGEZAL
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        instr_code = 7'd43; // LBU
        #1;
        assert (hazard == 1) else $error("hazard is %b, but it should be 1", hazard);
        #1;
        instr_code = 7'd47; // LW
        #1;
        assert (hazard == 1) else $error("hazard is %b, but it should be 1", hazard);
        #1;
        instr_code = 7'd52; // SW
        #1;
        assert (hazard == 1) else $error("hazard is %b, but it should be 1", hazard);
        #1;
        instr_code = 7'd46; // LUI
        #1;
        assert (hazard == 0) else $error("hazard is %b, but it should be 0", hazard);
        #1;
        $finish();
    end

    hazard_detector dut(.instruction_code(instr_code), .memory_hazard(hazard));

endmodule