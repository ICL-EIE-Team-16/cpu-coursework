module mips_bus_simple_tb;
    timeunit 1ns/10ps;

    parameter RAM_INIT_FILE = "test/test-cases/addiu-1/addiu-1.hex.txt";
    parameter WAVES_OUT_FILE = "test/test-cases/addiu-1/addiu-1.vcd";
    parameter TIMEOUT_CYCLES = 10000;

    logic clk;
    logic reset;
    logic reset_sent;
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

    simple_memory#(1024, RAM_INIT_FILE) ram(.clk(clk), .read(read), .write(write), .addr(address), .byteenable(byteenable), .writedata(writedata), .readdata(readdata), .waitrequest(waitrequest));
    mips_cpu_bus#(1) dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0), .address(address), .write(write), .read(read), .waitrequest(waitrequest), .writedata(writedata), .byteenable(byteenable), .readdata(readdata));

    initial begin
        $dumpfile(WAVES_OUT_FILE);
        $dumpvars(3, mips_bus_simple_tb);
        $display("REGFile : OUT: $zero,$at,$v0,$v1,$a0,$a1,$a2,$a3,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$t8,$t9,$k0,$k1,$gp,$sp,$s8,$ra");
    end

    // Generate clock
    initial begin
        clk = 0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
            $display("address: %h", address);
        end

        $finish;
        //$fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset = 0;
        reset_sent = 0;
        #40;
        reset = 1;
        #20;
        reset = 0;
        reset_sent = 1;
    end

    // When the active signal is LOW after the reset was driven HIGH, the test bench will be terminated, which means that the CPU was halted
    always @(posedge clk) begin
        if (~active && reset_sent) begin
            $display("REG v0: OUT: %h", register_v0);
            $finish;
        end
    end
endmodule