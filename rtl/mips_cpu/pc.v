module PC(
    input logic clk, reset,
    input logic fetch, exec1, exec2,
    input logic[6:0] instruction_code,
    input logic[15:0] offset,
    input logic[25:0] instr_index,
    input logic[31:0] register_data,
    input logic zero, positive, negative,
    output logic[31:0] address,
    output logic pc_halt
);
    logic[31:0] next_address; //next address to be fetched, PC gets updated with this value after each FETCH cycle.
    logic[31:0] jump_address, jump_address_reg;
    logic jump, jump_flag;

    typedef enum logic[6:0]{
        BEQ = 30,
        BGEZ = 31,
        BGEZAL = 32,
        BGTZ = 33,
        BLEZ = 34,
        BLTZ = 35,
        BLTZAL = 36,
        BNE = 37,
        J = 38,
        JAL = 39,
        JALR = 40,
        JR = 41
    } instruction_code_t;


    assign next_address = address+4;

    always @(*) begin

        if ((instruction_code == BEQ) && zero) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if ((instruction_code == BGTZ) && positive) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if ((instruction_code == BLEZ) && (zero || negative)) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if ((instruction_code == BNE) && (negative || positive)) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if (((instruction_code == BGEZ) || (instruction_code == BGEZAL)) && (positive || zero)) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if (((instruction_code == BLTZ) || (instruction_code == BLTZAL)) && negative) begin
            jump_address = address + {{14{offset[15]}}, offset, 2'b00};
            jump = 1;
        end
        else if ((instruction_code == JR) || (instruction_code == JALR)) begin
            jump_address = register_data;
            jump = 1;
        end
        else if ((instruction_code == J) || (instruction_code == JAL)) begin
            jump_address = {address[31:28], instr_index, 2'b00};
            jump = 1;
        end
        else begin
            jump = 0;
        end

        if (address == 0) begin
            pc_halt = 1;
        end
        else
            pc_halt = 0;

    end

    always_ff @(posedge clk) begin
        if (reset) begin
            address <= 32'hBFC00000;
        end
        else begin
            if (exec2) begin //fetch before
                if (pc_halt) begin
                    address <= 0;
                end
                else if (jump_flag) begin
                    address <= jump_address_reg;
                end
                else begin
                    address <= next_address;
                end

                if (jump) begin
                    jump_flag <= 1;
                    jump_address_reg <= jump_address;
                end
                else begin
                    jump_flag <= 0;
                    jump_address_reg <= 0;
                end
            end
        end
    end

endmodule