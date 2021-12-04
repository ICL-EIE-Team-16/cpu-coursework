module mips_cpu_bus_integration_tb ();
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
    $dumpvars(2, mips_cpu_bus_integration_tb);
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

    readdata = 32'h2442000f;
    #6;
    assert (register_v0 == 32'h0000000f) else $fatal(2, "problem with ADDIU instruction");
    readdata = 32'h241000fc;
    #6;
    readdata = 32'h241100ff;
    #6;
    readdata = 32'h02111021;
    #6;
    assert (register_v0 == 32'h000001FB) else $fatal(2, "problem with ADDU instruction");
    readdata = 32'h8e120004;
    #2;
    assert (address == 32'h00000100) else $fatal(2, "problem with LW instruction - wrong address calculated");
    #1;
    readdata = 32'h0000ffff;
    #3;
    readdata = 32'h8e130008;
    #2;
    assert (address == 32'h00000104) else $fatal(2, "problem with LW instruction - wrong address calculated");
    #1;
    readdata = 32'h00000001;
    #3;
    readdata = 32'h02721021;
    #6;
    assert (register_v0 == 32'h00010000) else $fatal(2, "problem with ADDU instruction");

end


mips_cpu_bus dut(.clk(clk), .reset(reset), .active(active), .register_v0(register_v0), .address(address), .write(write), .read(read), .waitrequest(waitrequest), .writedata(writedata), .byteenable(byteenable), .readdata(readdata));
endmodule