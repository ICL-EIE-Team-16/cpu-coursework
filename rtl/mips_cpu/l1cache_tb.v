module l1cache_tb();
logic clk;
logic read_ram;
logic write_ram;
logic[31:0] addr_ram;
logic[3:0] byteenable_ram;
logic [31:0] writedata_ram;
logic [31:0] readdata_ram;
logic waitrequest_ram;

logic read_cpu;
logic write_cpu;
logic[31:0] addr_cpu;
logic[3:0] byteenable_cpu;
logic [31:0] writedata_cpu;
logic [31:0] readdata_cpu;
logic waitrequest_cpu;

logic reset;
logic[31:0] count;

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, l1cache_tb);
end

initial begin
    clk = 0;
    repeat (100)
        #1 clk = ~clk;
    //$finish;
end

initial begin
    reset = 1;
    #2;
    reset=0;
    waitrequest_ram = 0;
    read_cpu =1;
    write_cpu =0;
    addr_cpu = 16;
    byteenable_cpu = 15;
    #10;
end

initial begin
    count = 0;
    readdata_ram = 0;
    repeat (100) begin
        readdata_ram = count;
        #2 count = count +1;

    end
end

l1cache dut(.reset(reset), .clk(clk), .read_cpu(read_cpu), .write_cpu(write_cpu), .addr_cpu(addr_cpu), .byteenable_cpu(byteenable_cpu), .writedata_cpu(writedata_cpu), .readdata_cpu(readdata_cpu), .waitrequest_cpu(waitrequest_cpu), .read_ram(read_ram), .write_ram(write_ram), .addr_ram(addr_ram), .byteenable_ram(byteenable_ram), .writedata_ram(writedata_ram), .readdata_ram(readdata_ram), .waitrequest_ram(waitrequest_ram));
endmodule