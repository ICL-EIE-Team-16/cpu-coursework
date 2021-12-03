module mips_cpu_bus_tb ();
 /* Standard signals */
logic clk;
logic reset;
logic active;
logic[31:0] register_v0;

/* Avalon memory mapped bus controller (master) */
logic[31:0] address;
logic write;
logic read;
logic waitrequest;
logic[31:0] writedata;
logic[3:0] byteenable;
logic[31:0] readdata;

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(3, mips_cpu_bus_tb);
end

initial begin
    clk = 0;
    repeat (1000)
        #1 clk = ~clk;
    $finish;
end

initial begin
     @(negedge active)
     $finish;
end

initial begin
    //Initialize
    waitrequest = 0;

    reset = 1;
    @(posedge clk)
    #1;
    reset = 0;

    readdata = 32'h2042000f;

end


mips_cpu_bus dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0), .address(address), .write(write), .read(read), .waitrequest(waitrequest), .writedata(writedata), .byteenable(byteenable), .readdata(readdata));
endmodule