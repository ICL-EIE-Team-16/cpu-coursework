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
    output logic halt
);
    logic[31:0] address_a; //PC+4 and PC+Branch_offset are multiplexed to give adress_a
    logic[31:0] address_b; //REG[rs] (jump register instruction) and PC[31:28]||jump_index||00 (jump instruction) 
    // are multiplexed to give adress_b (adress after a jump instrution)
    logic[31:0] next_address; //next adress to be fetched, PC gets updated with this value after each cycle.
    // adress_a and adress_b are multiplexed to give next_adress.

    enum logic[5:0] {SPECIAL, REGIMM, J, JAL, BEQ, BNE, BLEZ, BGTZ} opcode_def;
    enum logic[4:0] {BLTZ, BGEZ, BLTZAL=16, BGEZAL} branch_param_def;
    
    
    always @(*) begin
        
        if ((opcode == BEQ) && zero) begin
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else if ((opcode == BGTZ) && positive) begin
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else if ((opcode == BLEZ) && (zero || negative)) begin
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else if ((opcode == BNE) && (negative || positive)) begin
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else if ((opcode == REGIMM) && ((((branch_param == BGEZ) || (branch_param == BGEZAL)) && (positive || zero)) || (((branch_param == BLTZ) || (branch_param == BLTZAL)) && negative))) begin
            address_a = address + {{14{offset[15]}}, offset, 2'b00};
        end
        else begin
            address_a = address+4;
        end


        if (opcode == SPECIAL) begin     //If jump register instruction
            address_b = register_data;
        end
        else begin
            address_b = {address[31:28], instr_index, 2'b00};
        end


        if (((opcode == SPECIAL) || (opcode == J)) || (opcode == JAL)) begin //if jump (or jump register) instruction, i.e. OPcode = 000000 or 000010 or 000011
            next_address = address_b;
        end
        else begin
            next_address = address_a;
        end
            //This is the last multiplexer

        if (address == 0) begin
            halt = 1;
        end

    end

    always_ff @(posedge clk) begin
        if (reset == 1) begin
            address <= 32'hBFC00000;
        end
        else if (halt) begin
            address <= 0;
        end
        else if (cycle_1 == 1) begin
            address <= address;
        end
        else if (cycle_2 == 1) begin
            address <= next_address;
        end
    end
    
endmodule