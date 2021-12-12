module random_memory #(
parameter SIZE=1024,
parameter RAM_FILE = "ram.txt"
)(
    input logic clk,
    input logic read,
    input logic write,
    input logic[31:0] addr,
    input logic[3:0] byteenable,
    input logic [31:0] writedata,
    output logic [31:0] readdata,
    output logic waitrequest
);

//This memory is Avalon compliant and implements 1024 memory locations after
logic[31:0] mem[SIZE-1:0];
logic[31:0] offset, mem_read_word, mem_write_word;
logic[7:0] hi, lo, midhi, midlo;
assign offset = 32'hBFC00000;
logic[31:0] shifted_address, offset_address;

//Random generator vars
logic[6:0] shiftreg;
logic[4:0] delay;

//Memory initialization and loading
initial begin
        //Initialize everything to 0
        for (int i=0; i<SIZE; i++) begin
            mem[i]=0;
        end
        // Load contents from file if

        if (RAM_FILE != "") begin
            $display("Loading from %s", RAM_FILE);
            $readmemh(RAM_FILE, mem, 0, SIZE-1);
        end
        waitrequest = 1;
        delay = 0;
        shiftreg = 0;
    end


always @(*) begin
    shifted_address = addr - offset;
    offset_address = shifted_address>>2;
    mem_read_word = mem[offset_address];

    /*
    //Debugging error indicators
    if (shifted_address[1:0] != 0 && (read || write))
        $display("Memory error: unaligned address: %h", addr);
    if (read == 1 && write == 1)
        $display("Memory error: Simultaneous RW: %h", addr);
    */


    //Byteenable Implementation
    if(byteenable[0] == 1)
        hi = mem_read_word[31:24];
    else
        hi = 0;

    if(byteenable[1] == 1)
        midhi = mem_read_word[23:16];
    else
        midhi = 0;

    if(byteenable[2] == 1)
        midlo = mem_read_word[15:8];
    else
        midlo = 0;

    if(byteenable[3] == 1)
        lo = mem_read_word[7:0];
    else
        lo = 0;

end


always @(posedge clk) begin
    if (offset_address >= 0 && offset_address <= 1023) begin
        if (write == 1 & waitrequest == 0) begin
            for (int i=0; i<SIZE; i++) begin
                if ( offset_address == i) begin
                    mem[offset_address] <= (({{8{~byteenable[0]}}, {8{~byteenable[1]}}, {8{~byteenable[2]}}, {8{~byteenable[3]}}} & mem[offset_address]) | ({{8{byteenable[0]}}, {8{byteenable[1]}}, {8{byteenable[2]}}, {8{byteenable[3]}}} & writedata));
                end
                else begin
                    mem[i] <= mem[i];
                end
            end

        end
        else begin
            for (int i=0; i<SIZE; i++) begin
                mem[i] <= mem[i];
            end
        end

        if (read == 1 && waitrequest == 0)
            readdata<= {hi, midhi, midlo, lo};
        else begin
            readdata<=0;
        end

    end
    else if (read || write) begin
        $display("Memory error: Address range miss, only 1024 words after BFC00000 implemented by default. Increase RANGE parameter as required. ADDR:  %h", addr);
    end

end

always @(*) begin
    waitrequest = ~delay[3];
end

always @(posedge clk) begin

    //RNG shifting
    shiftreg[6]<= shiftreg[5];
    shiftreg[5]<= shiftreg[4];
    shiftreg[4]<= shiftreg[3];
    shiftreg[3]<= shiftreg[2];
    shiftreg[2]<= shiftreg[1];
    shiftreg[1]<= shiftreg[0];
    shiftreg[0]<= (1 ^ shiftreg[6] ^ shiftreg[5]);

    //Delay line shifting
    delay[3]<= delay[2];
    delay[2]<= delay[1];
    delay[1]<= delay[0];


    if((read || write ) && (delay == 0)) begin
        if (shiftreg[6:5] == 0) begin
            delay[0] <= 1;
        end
        else begin
            delay[shiftreg[6:5]] <= 1;
            delay[0] <= 0;
        end

    end
    else begin
        delay[0] <= 0;
    end

end

endmodule

