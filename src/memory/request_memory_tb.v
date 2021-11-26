module request_memory_tb ();
    logic clk;
    logic read;
    logic write;
    logic[31:0] addr;
    logic[3:0] byteenable;
    logic [31:0] writedata;
    logic [31:0] readdata;
    logic waitrequest;
       //Ram emulation setup
    parameter SIZE = 1024;
    parameter RAM_FILE = "ram.txt";
    logic[31:0] mem[SIZE-1:0];

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, request_memory_tb);

        //Initialize everything to 0
        for (int i=0; i<SIZE; i++) begin
            mem[i]=0;
        end
        /* Load contents from file if specified */
        $display("Loading from %s", RAM_FILE);
        $readmemh(RAM_FILE, mem, 0, SIZE-1);

        clk = 0;

         repeat (100) begin
            #1 clk = ~clk;
         end
    end

    initial begin
        // Dump ram
        read = 1;
        write = 0;
        byteenable = 4'hf;

        for(int i = 3217031168; i<(3217031168+100); i = i + 4) begin
            addr = i;
            @(posedge clk);
            @(posedge clk);
            #1;
            $display("mem[%h] = %h ", i, readdata);
            //assert (readdata == mem[4*i-3217031168]);
        end

        /*
        // Dump ram byteenable set to 0
        read = 1;
        write = 0;
        byteenable = 4'h0;

        for(int i = 3217031168; i<(3217031168+100); i++ ) begin
            addr = i;
            @(posedge clk);
            #1;
            //$display("mem[%h] = %h ", i, readdata);
            assert (readdata == 0);
        end
        */


        read = 0;
        write = 1;
        addr = 0;
        byteenable = 4'b1111;
        writedata = 4;

        @(posedge clk);
        #1;
    end


request_memory dut(.clk(clk), .read(read), .write(write), .addr(addr), .byteenable(byteenable), .writedata(writedata), .readdata(readdata), .waitrequest(waitrequest));
endmodule