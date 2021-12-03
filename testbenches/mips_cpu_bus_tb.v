module mips_cpu_bus_tb;
    timeunit 1ns/10ps;

    parameter RAM_INIT_FILE = "test/01-binary/countdown.hex.txt";
    parameter TIMEOUT_CYCLES = 10000;

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

    simple_memory#(1024, RAM_INIT_FILE) ram(.clk(clk), .read(read), .write(write), .addr(address), .byteenable(byteenable), .writedata(writedata), .readdata(readdata), .waitrequest(waitrequest));
    mips_cpu_bus dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0), .address(address), .write(write), .read(read), .waitrequest(waitrequest), .writedata(writedata), .byteenable(byteenable), .readdata(readdata));

    // Generate clock
    initial begin
        clk = 0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        reset = 0;
        #5;
        reset = 1;
        #20;
        reset = 0;
    end

    always @(negedge active) begin
        $display("REG v0: OUT: %h", register_v0);
        $finish;
    end
endmodule