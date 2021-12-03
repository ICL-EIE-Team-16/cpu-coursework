module mxu_tb ();
    logic fetch, exec1, exec2, read, write;
    logic[6:0] instcode;

    mxu mainmxu(.din(databus), .memin(readdata), .fetch(fetch), .ex1(exec1), .ex2(exec2), .in_instcode(instcode), .dataout(), .memout(writedata), .read(read), .write(write), .byteenable(byteenable));

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, mxu_tb);

    end

endmodule