
module mipsregisterfile(
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic [4:0] register_a_index, //register_one from IR_Decode
    input logic [4:0] register_b_index, //register_two from IR_Decode
    input logic [4:0] write_register, //destination_register from IR_Decode
    input logic [31:0] write_data,
    output logic [31:0] register_a_data, 
    output logic [31:0] register_b_data,
    output logic [31:0] v0
    );

    logic [31:0] regs [31:0];

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

    always_ff @(posedge clk ) begin
        if (reset==1) begin
            for(int i=0;i<32;i=i+1) begin
                regs[i] <= 0;
            end     
        end



        if(write_enable==1) begin
            regs[write_register] <= write_data;
        end
    end

    endmodule