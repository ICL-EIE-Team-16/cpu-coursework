module l1cache(
    input logic reset,
    input logic clk,

    //CPU side connections
    input logic read_cpu,
    input logic write_cpu,
    input logic[31:0] addr_cpu,
    input logic[3:0] byteenable_cpu,
    input logic [31:0] writedata_cpu,
    output logic [31:0] readdata_cpu,
    output logic waitrequest_cpu,

    //Ram side connections
    output logic read_ram,
    output logic write_ram,
    output logic[31:0] addr_ram,
    output logic[3:0] byteenable_ram,
    output logic [31:0] writedata_ram,
    input logic [31:0] readdata_ram,
    input logic waitrequest_ram
);

//This memory is Avalon compliant and implements 1024 memory locations after
logic[31:0] mem0[1024-1:0];
logic[31:0] mem1[1024-1:0];
logic[31:0] mem2[1024-1:0];
logic[31:0] mem3[1024-1:0];

//Queue variables
logic[31:0] address_queue[3:0];
logic[3:0] valid_queue;
logic last_queue_valid;
logic[31:0] last_queue_address;
logic[19:0] last_tag_ram;
logic last_ram_waitrequest;

logic[9:0] block_id_cpu, last_block_id_ram;
logic[19:0] tag[1024-1:0];
logic valid[1024-1:0];
logic[31:0] readdata_internal;

logic[31:0] ram_write_word;
logic[7:0] hi, lo, midhi, midlo;
logic[19:0] tag_cpu;
logic hit, last_hit, last_cpu_write, last_cpu_read, last_ram_write, last_ram_read;

//Viewers of address queue
logic[31:0] viewer_address_queue0;
assign viewer_address_queue0 = address_queue[0];
logic[31:0] viewer_address_queue1;
assign viewer_address_queue1 = address_queue[1];
logic[31:0] viewer_address_queue2;
assign viewer_address_queue2 = address_queue[2];
logic[31:0] viewer_address_queue3;
assign viewer_address_queue3 = address_queue[3];

logic viewer_valid;
assign viewer_valid = valid[4];
logic[19:0] viewer_tag;
assign viewer_tag = tag[4];
logic[31:0] viewer_mem0;
assign viewer_mem0 = mem0[4];
logic[31:0] viewer_mem1;
assign viewer_mem1 = mem1[4];
logic[31:0] viewer_mem2;
assign viewer_mem2 = mem2[4];
logic[31:0] viewer_mem3;
assign viewer_mem3 = mem3[4];


//Reset initialization
always @(posedge clk) begin
    readdata_cpu <= {hi, midhi, midlo, lo};
    last_queue_address <= address_queue[0];
    last_ram_waitrequest <= waitrequest_ram;
    last_queue_valid <= valid_queue[0];
    last_ram_write <= write_ram;
    last_ram_read <= read_ram;

    if(reset) begin
        valid_queue<= 0;
        last_queue_valid <= 0;
        for( int i =0; i < 1024 ; i++) begin
            valid[i] <= 0;
            tag[i] <= 0;
        end
    end
    else begin
        //Write bodge
        if(hit & write_cpu) begin
            valid[block_id_cpu] <=0;
        end

       //Writeback
        if (~last_ram_waitrequest & last_queue_valid & ~last_ram_write & last_ram_read) begin
            if(last_queue_address[1:0] == 0) begin
                mem0[last_block_id_ram]<=readdata_ram;
            end
            else if(last_queue_address[1:0] == 1) begin
                mem1[last_block_id_ram]<=readdata_ram;
            end
            else if(last_queue_address[1:0] == 2) begin
                mem2[last_block_id_ram]<=readdata_ram;
            end
            else if(last_queue_address[1:0] == 3) begin
                mem3[last_block_id_ram]<=readdata_ram;
            end
        end


        //Queue fill
        if(read_cpu & ~hit & valid_queue == 0 & ~last_queue_valid) begin
            valid_queue <= 15;
            address_queue[3] <= {addr_cpu[31:2], 2'b00};
            address_queue[2] <= {addr_cpu[31:2], 2'b01};
            address_queue[1] <= {addr_cpu[31:2], 2'b10};
            address_queue[0] <= {addr_cpu[31:2], 2'b11};
        end
        //Queue shift
        else if(~waitrequest_ram & ~write_cpu) begin

            //Valid queue
            valid_queue[3] <= 0;
            valid_queue[2] <= valid_queue[3];
            valid_queue[1] <= valid_queue[2];
            valid_queue[0] <= valid_queue[1];

            //Address queue
            address_queue[3] <= 0;
            address_queue[2] <= address_queue[3];
            address_queue[1] <= address_queue[2];
            address_queue[0] <= address_queue[1];

        end
        //Block loading finished
        if(valid_queue == 0 && last_queue_valid) begin
            valid[last_block_id_ram] <= 1;
        end
    end
end

//Cpu waitreq control and word resolution

always @(*) begin
    //Misc decoding
    tag_cpu = addr_cpu[31: 12];
    block_id_cpu = addr_cpu[11 :2];
    hit = valid[block_id_cpu] && (tag[block_id_cpu] == tag_cpu);
    last_tag_ram = last_queue_address[2 : 2];
    last_block_id_ram = last_queue_address[11 :2];


    if(write_cpu) begin
            write_ram = 1;
            read_ram = 0;
            addr_ram = addr_cpu;
            writedata_ram = writedata_cpu;
    end
    else if(read_cpu)begin
        write_ram = 0;
        addr_ram = address_queue[0];
        if(hit) begin
            waitrequest_cpu = 0;
            read_ram = 0;
            if(addr_cpu[1:0] == 0) begin
               readdata_internal = mem0[block_id_cpu];
            end
            else if(addr_cpu[1:0] == 1) begin
               readdata_internal = mem1[block_id_cpu];
            end
            else if(addr_cpu[1:0] == 2) begin
               readdata_internal = mem2[block_id_cpu];
            end
            else begin
               readdata_internal = mem3[block_id_cpu];
            end
        end
        else if(valid_queue != 0) begin
            waitrequest_cpu = 1;
            readdata_internal = 0;
            read_ram = 1;
        end
        else begin
            waitrequest_cpu = 1;
            readdata_internal = 0;
            read_ram = 0;

        end
    end
    else begin
        write_ram = 0;
        read_ram = 1;
    end

    //Byteenable Implementation
    if(byteenable_cpu[0] == 1)
        hi = readdata_internal[31:24];
    else
        hi = 0;

    if(byteenable_cpu[1] == 1)
        midhi = readdata_internal[23:16];
    else
        midhi = 0;

    if(byteenable_cpu[2] == 1)
        midlo = readdata_internal[15:8];
    else
        midlo = 0;

    if(byteenable_cpu[3] == 1)
        lo = readdata_internal[7:0];
    else
        lo = 0;


    //Ram byteenable
    if(write_cpu) begin
        byteenable_ram = byteenable_cpu;
    end
    else begin
        byteenable_ram = 15;
    end
end


endmodule