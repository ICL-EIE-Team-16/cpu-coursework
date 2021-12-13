module mipsregisterfile#(
    parameter DISP_VALS_TO_OUT = 0
)(
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic[4:0] register_a_index, //register_one from IR_Decode
    input logic[4:0] register_b_index, //register_two from IR_Decode
    input logic[4:0] write_register, //destination_register from IR_Decode
    input logic[31:0] write_data,
    output logic[31:0] register_a_data,
    output logic[31:0] register_b_data,
    output logic[31:0] v0
);

    logic[31:0] regs[31:0];

    always_comb begin
        if (register_a_index != 0)
            register_a_data = regs[register_a_index];
        else
            register_a_data = 0;

        if (register_b_index != 0)
            register_b_data = regs[register_b_index];
        else
            register_b_data = 0;

        v0 = regs[2];
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32;i = i+1) begin
                regs[i] <= 0;
            end
        end
        else if (write_enable) begin
            regs[write_register] <= write_data;
        end

        /* Placing this above the conditions above broke register file resetting*/
        if (DISP_VALS_TO_OUT == 1)
              $display("REGFile : OUT: %h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h,%h",
                regs[0], regs[1], regs[2], regs[3], regs[4], regs[5], regs[6], regs[7], regs[8], regs[9], regs[10], regs[11], regs[12],
                regs[13], regs[14], regs[15], regs[16], regs[17], regs[18], regs[19], regs[20], regs[21], regs[22], regs[23], regs[24],
                regs[25], regs[26], regs[27], regs[28], regs[29], regs[30], regs[31]);
    end

endmodule