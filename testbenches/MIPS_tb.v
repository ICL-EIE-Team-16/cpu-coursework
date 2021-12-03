module MIPS_tb;
    timeunit 1ns/10ps;

    parameter RAM_INIT_FILE = "test/01-binary/countdown.hex.txt";
    parameter TIMEOUT_CYCLES = 10000;

    logic clk;
    logic reset;
    logic active;

    logic running;

    logic[11:0] address;
    logic write;
    logic read;
    logic[31:0] writedata;
    logic[31:0] readdata;
    logic[31:0] register_v0;

    RAM_32x4096_delay1#(RAM_INIT_FILE) ramInst(clk, address, write, read, writedata, readdata);
    mips_cpu dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0));

    // Generate clock
    initial begin
        clk = 0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end
        $display("REG : INFO : $zero,$at,$v0,$v1,$a0,$a1,$a2,$a3,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$t8,$t9,$k0,$k1,$gp,$sp,$s8,$ra");

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset = 0;
        #5;
        address = 0;
        #20;

        $display("REG : INFO : 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
        $display("Memory OUT: %h", readdata);

        address = 1;
        #20;

        $display("Memory OUT: %h", readdata);

        address = 2;
        #20;

        $display("Memory OUT: %h", readdata);

        address = 3;
        #20;

        $display("Memory OUT: %h", readdata);

        address = 4;
        #20;

        $display("Memory OUT: %h", readdata);
        $display("TB : finished; running=0");

        #5;

        reset = 1;

        #20;
        reset = 0;

        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 32'h00010000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 32'h00010000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 32'h00010000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        $display("REG : INFO : %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h", 0, 0, 32'h00010000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32'h10, 32'hffff, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        #1000;
    end

    always @(negedge active) begin
        $display("REG v0: OUT: %h", register_v0);
        $finish;
    end
endmodule