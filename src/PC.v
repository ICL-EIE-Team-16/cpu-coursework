module PC (
    input logic clk, reset,
    input logic cycle_1, cycle_2,
    //input logic[31:0] instruction,
    input logic [5:0] opcode,
    input logic[15:0] offset,
    input logic[25:0] instr_index,
    input logic[4:0] branch_param,
    input logic[31:0] register_data,
    input logic zero, positive, negative,
    output logic[31:0] address,
    output logic active
);
    logic[31:0] address_a; //PC+4 and PC+Branch_offset are multiplexed to give adress_a
    logic[31:0] address_b; //REG[rs] (jump register instruction) and PC[31:28]||jump_index||00 (jump instruction) 
    // are multiplexed to give adress_b (adress after a jump instrution)
    logic[31:0] next_address; //next adress to be fetched, PC gets updated with this value after each cycle.
    // adress_a and adress_b are multiplexed to give next_adress.

    enum logic[5:0] {SPECIAL, REGIMM, J, JAL, BEQ, BNE, BLEZ, BGTZ} opcode_in;
    assign opcode_in = opcode;
    
    always @(*) begin
        
        if (((opcode == 4) && zero) || ((opcode == 7) && positive) || ((opcode == 6) && (zero || negative)) || ((opcode == 5) && (negative || positive)) || ((opcode == 1) && ((((rt == 1) || (rt == 17)) && (positive || zero)) || (((rt == 0) || (rt == 16)) && negative)))) begin
        // if (BEQ   and    zero)  or   (BGTZ    and   positive)  or   (BLEZ  and  (zero  or  negative))   or   (BNE  and  (negative  or   positive))   or    (REGIMM    and  (((BGEZ or BGEZAL) and (positive or zero)) or ((BLTZ or BLTZAL) and negative)))
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else begin
            address_a = address+4;
        end


        if (opcode == 0) begin     //If jump register instruction
            address_b = register_data;
        end
        else begin
            address_b = {address[31:28], instr_index, 2'b00};
        end


        if (((opcode == 0) || (opcode == 2)) || (opcode == 3)) begin //if jump (or jump register) instruction, i.e. OPcode = 000000 or 000010 or 000011
            next_address = address_b;
        end
        else begin
            next_address = address_a;
        end
            //This is the last multiplexer

    end

    always_ff @(posedge clk) begin
        if (reset == 1) begin
            address <= 32'hBFC00000;
        end
        else if (cycle_1 == 1) begin
            address <= address;
        end
        else if (cycle_2 == 1) begin
            address <= next_address;
        end
    end
    
endmodule