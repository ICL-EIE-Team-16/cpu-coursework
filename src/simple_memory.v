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
logic[31:0] offset;
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

    //Debugging error indicators
    if (shifted_address[1:0] != 0)
        $display("Memory error: unaligned address: %h", addr);
    if (read == 1 && write == 1)
        $display("Memory error: Simultaneous RW: %h", addr);

    //Byteenable Implementation
    if(byteenable[0] == 1)
        hi = mem[offset_address][31:24];
    else
        hi = 0;

    if(byteenable[1] == 1)
        midhi = mem[offset_address][23:16];
    else
        midhi = 0;

    if(byteenable[2] == 1)
        midlo = mem[offset_address][15:8];
    else
        midlo = 0;

    if(byteenable[3] == 1)
        lo = mem[offset_address][7:0];
    else
        lo = 0;

end


always @(posedge clk) begin
    if (offset_address >= 0 && offset_address <= 1023) begin
        if (write == 1)
            mem[offset_address] <= writedata;
        else if (read == 1)
            readdata<= {hi, midhi, midlo, lo};
        else
            readdata<=15;

    end
    else begin
        $display("Memory error: Address range miss, only 1024 words after BFC00000 implemented by default. Increase RANGE parameter as required. ADDR:  %h", addr);
    end

end



endmodule