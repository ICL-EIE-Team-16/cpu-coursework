module simple_memory #(
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
logic t;

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
    end


always @(*) begin
    waitrequest = 0;
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
        if (write == 1) begin
            for (int i=0; i<SIZE; i++) begin
                if ( offset_address == i) begin
                    mem[offset_address] <= (({{8{~byteenable[0]}}, {8{~byteenable[1]}}, {8{~byteenable[2]}}, {8{~byteenable[3]}}} & mem[offset_address]) | ({{8{byteenable[0]}}, {8{byteenable[1]}}, {8{byteenable[2]}}, {8{byteenable[3]}}} & {writedata[7:0], writedata[15:8], writedata[23:16], writedata[31:24]}));
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

        if (read == 1)
            readdata<= {lo, midlo, midhi, hi};
        else begin
            readdata<=0;
        end

    end
    else if (read || write) begin
        $display("Memory error: Address range miss, only 1024 words after BFC00000 implemented by default. Increase RANGE parameter as required. ADDR:  %h", addr);
    end

end



endmodule