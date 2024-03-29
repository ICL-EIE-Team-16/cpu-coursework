module mips_cpu_bus#(
    parameter DISP_REG_VALS_TO_OUT = 0
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

    logic fetch, exec1, exec2, reg_write_en, pc_halt, mem_halt, zero, positive, negative, alu_exception;
    logic[31:0] databus, alu_b, alu_a, reg_a_out, reg_b_out, pc_address, immediate, reg_in, alu_r, mxu_dout, readdata_unscrambled, writedata_unscrambled;
    logic[4:0] reg_a_idx, reg_b_idx, reg_in_idx, shift_amount;
    logic[25:0] jump_const;
    logic[6:0] instruction_code;
    assign alu_a = reg_a_out;

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


//MUX @ ALU B input
    always_comb begin
        //Split into multiple statements for readability- Immediate instrucitons
        if (instruction_code == ADDI || instruction_code == ADDIU || instruction_code == ANDI || instruction_code == ORI)
            alu_b = immediate;
        else if (instruction_code == SLTI || instruction_code == SLTIU || instruction_code == XORI)
            alu_b = immediate;

        // Memory control
        else if (instruction_code == SB || instruction_code == SH || instruction_code == SW )
            alu_b = immediate;
        else if (instruction_code == LB || instruction_code == LBU || instruction_code == LH || instruction_code == LHU)
            alu_b = immediate;
        else if (instruction_code == LUI || instruction_code == LW || instruction_code == LWL || instruction_code == LWR)
            alu_b = immediate;
        else
            alu_b = reg_b_out;
    end

//MUX @ ALU A input
    /*
    always_comb begin
        //Supplies ALU with pc_address for for AL type instructions to calculate PC+8
        if (exec2 && (instruction_code == BGEZAL || instruction_code == BLTZAL || instruction_code == JAL || instruction_code == JALR))
            alu_a = pc_address;
        else
            alu_a = reg_a_out;
    end
    */

//MUX @REG_IN
    always_comb begin
        if (instruction_code == LB || instruction_code == LBU || instruction_code == LH || instruction_code == LHU)
            reg_in = mxu_dout;
        else if (instruction_code == LW || instruction_code == LWL || instruction_code == LWR)
            reg_in = mxu_dout;
        else if (instruction_code == BGEZAL || instruction_code == BLTZAL || instruction_code == JAL || instruction_code == JALR)
            reg_in = pc_address + 31'd8;
        else if (instruction_code == LUI)
            reg_in = immediate;
        else
            reg_in = alu_r;
    end

    statemachine sm(.clk(clk), .reset(reset), .halt(pc_halt||mem_halt), .fetch(fetch), .exec1(exec1), .exec2(exec2));
    mxu mainmxu(.waitrequest(waitrequest), .mxu_reg_b_in(reg_b_out), .memin(readdata_unscrambled), .fetch(fetch), .exec1(exec1), .exec2(exec2), .instruction_code(instruction_code), .pc_address(pc_address), .alu_r(alu_r), .mem_address(address), .dataout(mxu_dout), .memout(writedata_unscrambled), .read(read), .write(write), .byteenable(byteenable), .mem_halt(mem_halt));
    ALU mainalu(.reset(reset), .clk(clk), .fetch(fetch), .exec1(exec1), .exec2(exec2), .a(reg_a_out), .b(alu_b), .op(instruction_code), .sa(shift_amount), .zero(zero), .positive(positive), .negative(negative), .r(alu_r), .exception(alu_exception));
    mipsregisterfile#(DISP_REG_VALS_TO_OUT) regfile(.clk(clk), .reset(reset), .write_enable(reg_write_en && ~(pc_halt || mem_halt)), .register_a_index(reg_a_idx), .register_b_index(reg_b_idx), .write_register(reg_in_idx), .write_data(reg_in), .register_a_data(reg_a_out), .register_b_data(reg_b_out), .v0(register_v0));
    IR_decode ir(.clk(clk), .current_instruction(readdata_unscrambled), .fetch(fetch), .exec1(exec1), .exec2(exec2), .shift_amount(shift_amount), .destination_reg(reg_in_idx), .reg_b_idx(reg_b_idx), .reg_a_idx(reg_a_idx), .immediate(immediate), .memory(jump_const), .reg_write_en(reg_write_en), .instruction_code(instruction_code));
    PC pc(.clk(clk), .reset(reset), .fetch(fetch), .exec1(exec1), .exec2(exec2), .interrupt_signal(alu_exception), .instruction_code(instruction_code), .offset(immediate[15:0]), .instr_index(jump_const), .register_data(reg_a_out), .zero(zero), .positive(positive), .negative(negative), .address(pc_address), .pc_halt(pc_halt));

endmodule