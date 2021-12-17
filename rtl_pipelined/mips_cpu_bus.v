module mips_cpu_bus#(
    parameter DISP_REG_VALS_TO_OUT=0
)(
    /* Standard signals */
    input logic clk,
    input logic reset,
    output logic active,
    output logic[31:0] register_v0,

    /* Avalon memory mapped bus controller (master) */
    output logic[31:0] address,
    output logic write,
    output logic read,
    input logic waitrequest,
    output logic[31:0] writedata,
    output logic[3:0] byteenable,
    input logic[31:0] readdata
);

    logic fetch, exec1, exec2, reg_write_en, pc_halt, mem_halt, zero, positive, negative, is_current_instruction_valid, ignore_forwarding, memory_hazard, correct_op, registers_match;
    logic[31:0] databus, alu_b, alu_a, reg_a_out, reg_b_out, pc_address, immediate_1, immediate_2, reg_in, alu_r, mxu_dout, alu_r_saved, return_address, jump_register_data, readdata_unscrambled, writedata_unscrambled, mxu_reg_b_in, alu_r_mxu;
    logic[4:0] reg_a_idx_1, reg_a_idx_2, reg_b_idx_1, reg_b_idx_2, destination_reg_1, reg_in_idx, shift_amount, reg_b_bodge;
    logic[25:0] jump_const;
    logic[6:0] instruction_code_1, instruction_code_2;

    typedef enum logic[6:0]{
        ADD = 7'd1,
        ADDI = 7'd2,
        ADDIU = 7'd3,
        ADDU = 7'd4,
        AND = 7'd5,
        ANDI = 7'd6,
        DIV = 7'd7,
        DIVU = 7'd8,
        MFHI = 7'd9,
        MFLO = 7'd10,
        MTHI = 7'd11,
        MTLO = 7'd12,
        MULT = 7'd13,
        MULTU = 7'd14,
        OR = 7'd15,
        ORI = 7'd16,
        SLL = 7'd17,
        SLLV = 7'd18,
        SLT = 7'd19,
        SLTI = 7'd20,
        SLTIU = 7'd21,
        SLTU = 7'd22,
        SRA = 7'd23,
        SRAV = 7'd24,
        SRL = 7'd25,
        SRLV = 7'd26,
        SUBU = 7'd27,
        XOR = 7'd28,
        XORI = 7'd29,

        BEQ = 7'd30,
        BGEZ = 7'd31,
        BGEZAL = 7'd32,
        BGTZ = 7'd33,
        BLEZ = 7'd34,
        BLTZ = 7'd35,
        BLTZAL = 7'd36,
        BNE = 7'd37,
        J = 7'd38,
        JAL = 7'd39,
        JALR = 7'd40,
        JR = 7'd41,

        LB = 7'd42,
        LBU = 7'd43,
        LH = 7'd44,
        LHU = 7'd45,
        LUI = 7'd46,
        LW = 7'd47,
        LWL = 7'd48,
        LWR = 7'd49,
        SB = 7'd50,
        SH = 7'd51,
        SW = 7'd52

    } instruction_t;

//Halt flip && scrambling
    always @(*) begin
        active = ~pc_halt;
        readdata_unscrambled = {readdata[7:0], readdata[15:8], readdata[23:16], readdata[31:24]};
        writedata = {writedata_unscrambled[7:0], writedata_unscrambled[15:8], writedata_unscrambled[23:16], writedata_unscrambled[31:24]};
    end

//Ignore data forwarding
    always_comb begin
        ignore_forwarding = instruction_code_2 == BGTZ || instruction_code_2 == DIV || instruction_code_2 == DIVU
            || instruction_code_2 == MTHI || instruction_code_2 == MTLO || instruction_code_2 == MULT || instruction_code_2 == MULTU
            || instruction_code_2 == BEQ || instruction_code_2 == BGEZ || instruction_code_2 == BGEZAL || instruction_code_2 == BGTZ
            || instruction_code_2 == BLEZ || instruction_code_2 == BLTZ || instruction_code_2 == BLTZAL || instruction_code_2 == BNE
            || instruction_code_2 == J || instruction_code_2 == JAL || instruction_code_2 == JR || instruction_code_2 == SB || instruction_code_2 == SH || instruction_code_2 == SW;
    end

//MUX @ ALU B input
    always_comb begin
        //Split into multiple statements for readability- Immediate instrucitons
        if (instruction_code_1 == ADDI || instruction_code_1 == ADDIU || instruction_code_1 == ANDI || instruction_code_1 == ORI)
            alu_b = immediate_1;
        else if (instruction_code_1 == SLTI || instruction_code_1 == SLTIU || instruction_code_1 == XORI)
            alu_b = immediate_1;

            // Memory control
        else if (instruction_code_1 == SB || instruction_code_1 == SH || instruction_code_1 == SW)
            alu_b = immediate_1;
        else if (instruction_code_1 == LB || instruction_code_1 == LBU || instruction_code_1 == LH || instruction_code_1 == LHU)
            alu_b = immediate_1;
        else if (instruction_code_1 == LUI || instruction_code_1 == LW || instruction_code_1 == LWL || instruction_code_1 == LWR)
            alu_b = immediate_1;
        else if (reg_b_idx_1 == reg_in_idx && !ignore_forwarding) // TODO: maybe need to add NOP
            alu_b = alu_r_saved;
        else
            alu_b = reg_b_out;
    end

//MUX @ ALU A input
    always_comb begin
        //Supplies ALU with pc_address for for AL type instructions to calculate PC+8
        /*if (exec2 && (instruction_code == BGEZAL || instruction_code == BLTZAL || instruction_code == JAL || instruction_code == JALR))
            alu_a = pc_address;
        else
            alu_a = reg_a_out;*/
        correct_op = instruction_code_2 == LUI;
        registers_match = reg_a_idx_1 == reg_in_idx;
        if (registers_match && correct_op) begin
            alu_a = immediate_2;
        end else if (reg_a_idx_1 == reg_in_idx && !ignore_forwarding) begin
            alu_a = alu_r_saved;
        end else
            alu_a = reg_a_out;
    end

//MUX @REG_IN
    always_comb begin
        if (instruction_code_2 == LB || instruction_code_2 == LBU || instruction_code_2 == LH || instruction_code_2 == LHU)
            reg_in = mxu_dout;
        else if (instruction_code_2 == LW || instruction_code_2 == LWL || instruction_code_2 == LWR)
            reg_in = mxu_dout;
        else if (instruction_code_2 == BGEZAL || instruction_code_2 == BLTZAL || instruction_code_2 == JAL || instruction_code_2 == JALR)
            reg_in = return_address;
        else if (instruction_code_2 == LUI)
            reg_in = immediate_2;
        else
            reg_in = alu_r_saved;
    end

//MUX for jump register
    always_comb begin
        if (reg_a_idx_1 == reg_in_idx && !ignore_forwarding)
            jump_register_data = alu_r_saved;
        else
            jump_register_data = reg_a_out;
    end

//MUX MXU reg in
    always_comb begin
        if (reg_in_idx == reg_b_idx_1) begin
            mxu_reg_b_in = alu_r_saved;
        end else begin
            mxu_reg_b_in = reg_b_out;
        end
    end

// MUX MXU ALU result
    always_comb begin
        if (instruction_code_2 == LB || instruction_code_2 == LBU || instruction_code_2 == LH || instruction_code_2 == LHU
            || instruction_code_2 == LUI || instruction_code_2 == LWL || instruction_code_2 == LWR)
            alu_r_mxu = alu_r_saved;
        else
            alu_r_mxu = alu_r;
    end

//Data forwarding register
    always_ff @(posedge clk) begin
        is_current_instruction_valid <= 1;
        alu_r_saved <= alu_r;
    end

    always @(*) begin
        //LWR/LWL bodge
        if(instruction_code_2 == LWL || instruction_code_2 == LWR) begin
            reg_b_bodge = reg_in_idx;
        end
        else begin
            reg_b_bodge = reg_b_idx_1;
        end
    end

    statemachine sm(.clk(clk), .reset(reset), .halt(pc_halt || mem_halt), .fetch(fetch), .exec1(exec1), .exec2(exec2));
    mxu mainmxu(.waitrequest(waitrequest), .mxu_reg_b_in(mxu_reg_b_in), .memin(readdata_unscrambled), .fetch(fetch), .exec1(exec1), .exec2(exec2), .instruction_code_1(instruction_code_1), .instruction_code_2(instruction_code_2), .pc_address(pc_address), .alu_r(alu_r_mxu), .mem_address(address), .dataout(mxu_dout), .memout(writedata_unscrambled), .read(read), .write(write), .byteenable(byteenable), .mem_halt(mem_halt));
    ALU mainalu(.reset(reset), .clk(clk), .fetch(fetch), .exec1(exec1), .exec2(exec2), .a(alu_a), .b(alu_b), .op(instruction_code_1), .sa(shift_amount), .zero(zero), .positive(positive), .negative(negative), .r(alu_r));
    mipsregisterfile#(DISP_REG_VALS_TO_OUT) regfile(.clk(clk), .reset(reset), .write_enable(reg_write_en && ~(pc_halt)), .register_a_index(reg_a_idx_1), .register_b_index(reg_b_bodge), .write_register(reg_in_idx), .write_data(reg_in), .register_a_data(reg_a_out), .register_b_data(reg_b_out), .v0(register_v0));
    IR_decode ir(
        .clk(clk), .current_instruction(readdata_unscrambled), .is_current_instruction_valid(is_current_instruction_valid), .fetch(fetch), .exec1(exec1), .exec2(exec2),
        .shift_amount(shift_amount), .destination_reg_1(destination_reg_1), .destination_reg_2(reg_in_idx), .reg_a_idx_1(reg_a_idx_1), .reg_a_idx_2(reg_a_idx_2), .reg_b_idx_1(reg_b_idx_1), .reg_b_idx_2(reg_b_idx_2),
        .immediate_1(immediate_1), .immediate_2(immediate_2), .memory(jump_const), .reg_write_en(reg_write_en), .instruction_code_1(instruction_code_1), .instruction_code_2(instruction_code_2),
        .memory_hazard(memory_hazard), .waitrequest(waitrequest)
    );
    PC pc(.clk(clk), .reset(reset), .fetch(fetch), .exec1(exec1), .exec2(exec2), .instruction_code(instruction_code_1), .offset(immediate_1[15:0]), .instr_index(jump_const), .register_data(jump_register_data), .zero(zero), .positive(positive), .negative(negative), .address(pc_address), .pc_halt(pc_halt), .return_address(return_address), .memory_hazard(memory_hazard), .waitrequest(waitrequest));

endmodule