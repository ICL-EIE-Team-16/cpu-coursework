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

logic[31:0] mem[1023*4];

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
    byteenable_cpu = 15;

    //Read testing
    //(Write through only, resets block valid flag if found)
    addr_cpu = 16;
    #2;
    while(waitrequest_cpu) begin
        #1;
    end
    #5;

    //From cached block
    addr_cpu = 17;
    #10;

    //From new block to fetch
    addr_cpu = 22;
    #2;
    while(waitrequest_cpu) begin
        #1;
    end
    #5;

    //From cached block
    addr_cpu = 23;
    @(posedge clk);
    #1;

    while(waitrequest_cpu) begin
        #1;
    end
    #10;
    $finish;
end


//Memory emulation
initial begin
    for(int i =0; i<1024*4; i++) begin
        mem[i] = 16*i+1;
    end
end

assign readdata_ram = mem[addr_ram];

l1cache dut(.reset(reset), .clk(clk), .read_cpu(read_cpu), .write_cpu(write_cpu), .addr_cpu(addr_cpu), .byteenable_cpu(byteenable_cpu), .writedata_cpu(writedata_cpu), .readdata_cpu(readdata_cpu), .waitrequest_cpu(waitrequest_cpu), .read_ram(read_ram), .write_ram(write_ram), .addr_ram(addr_ram), .byteenable_ram(byteenable_ram), .writedata_ram(writedata_ram), .readdata_ram(readdata_ram), .waitrequest_ram(waitrequest_ram));
endmodule