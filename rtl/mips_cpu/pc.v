module PC(
    input logic clk, reset,
    input logic fetch, exec1, exec2,
    input logic interrupt_signal,
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
    logic[31:0] resume_address; //register used to store the address of the instruction to resume the main program execution once the ISR is done
    logic[3:0] isr_counter; // counts up to 10 during execution of the ISR then resumes main flow of instructions
    logic interrupt;


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
            isr_counter <= 0;
        end
        if (interrupt_signal && (isr_counter == 0)) begin //if there is an interrupt and we aren't already in an isr:
            interrupt <= 1;
            resume_address <= next_address;
        end
        else begin
            if (exec2) begin //fetch before
                if (pc_halt) begin
                    address <= 0;
                end
                else if (interrupt) begin //this will initiate an ISR
                    address <= 32'hBFCF0000;  //PC jumps to hardcoded address of ISR
                    interrupt <= 0;       //interrupt flag is set to low so the CPU doesn't start an ISR during an ISR
                    isr_counter <= isr_counter+1; //counter to 10 instrucitons
                end
                else if (isr_counter > 0) begin // if an ISR is executing
                    if (isr_counter ==10) begin // if we have reached the end of the ISR: CPU automatically returns from ISR once 10 ISR instructions have been executed
                        address <= resume_address; // PC jumps back to the resume_address before the interrupt
                        isr_counter <= 0;    //counter to 10 of the ISR is reset
                        resume_address <= 0; // resume_address is cleared
                    end
                    else begin                          // if we are still in the middle of an ISR
                        address <= next_address;        // PC incremented by 4
                        isr_counter <= isr_counter+1;   //counter to 10 incremented
                    end
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