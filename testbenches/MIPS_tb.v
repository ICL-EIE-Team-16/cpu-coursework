module MIPS_tb;
    timeunit 1ns / 10ps;

    parameter RAM_INIT_FILE = "test/01-binary/countdown.hex.txt";
    parameter TIMEOUT_CYCLES = 10000;

    logic clk;
    logic rst;

    logic running;

    logic[11:0] address;
    logic write;
    logic read;
    logic[31:0] writedata;
    logic[31:0] readdata;

    RAM_32x4096_delay1 #(RAM_INIT_FILE) ramInst(clk, address, write, read, writedata, readdata);

    // Generate clock
    initial begin
        clk=0;

        repeat (TIMEOUT_CYCLES) begin
            #10;
            clk = !clk;
            #10;
            clk = !clk;
        end

        $fatal(2, "Simulation did not finish within %d cycles.", TIMEOUT_CYCLES);
    end

    initial begin
        #10;

        $display("TB : finished; running=0");

        $finish;

    end
endmodule