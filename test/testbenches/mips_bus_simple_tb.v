module mips_bus_simple_tb;
    timeunit 1ns/10ps;

    parameter RAM_INIT_FILE = "test/test-cases/addiu-1/addiu-1.hex.txt";
    parameter WAVES_OUT_FILE = "test/test-cases/addiu-1/addiu-1.vcd";
    parameter TIMEOUT_CYCLES = 20000;

    logic clk;
    logic reset;
    logic active;
    logic waitrequest;
    logic running;

    logic[31:0] address;
    logic write;
    logic read;
    logic[31:0] writedata;
    logic[31:0] readdata;
    logic[31:0] register_v0;
    logic[3:0] byteenable;
    logic[31:0] num;
    logic[4:0] sa;

    simple_memory#(1024, RAM_INIT_FILE) ram(.clk(clk), .read(read), .write(write), .addr(address), .byteenable(byteenable), .writedata(writedata), .readdata(readdata), .waitrequest(waitrequest));
    mips_cpu_bus#(1) dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0), .address(address), .write(write), .read(read), .waitrequest(waitrequest), .writedata(writedata), .byteenable(byteenable), .readdata(readdata));

    initial begin
        $dumpfile(WAVES_OUT_FILE);
        $dumpvars(3, mips_bus_simple_tb);
    end

    // Generate clock
    initial begin
        clk = 0;
        num = 32'h80000000;
        sa = 5'b10100;
        $display("num: %b: ", num);
        $display("shifted num: %b: ", num >>> (sa));

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
            $display("address: %h", address);
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        $display("REGFile : OUT: $zero,$at,$v0,$v1,$a0,$a1,$a2,$a3,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$t8,$t9,$k0,$k1,$gp,$sp,$s8,$ra");
        reset = 0;
        #5;
        reset = 1;
        #20;
        reset = 0;
    end

    always @(posedge clk) begin
        if(~active) begin
        $display("REG v0: OUT: %h", register_v0);
        $finish;
        end
    end
endmodule