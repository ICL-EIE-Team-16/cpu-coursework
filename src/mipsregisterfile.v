
module mipsregisterfile(
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic [31:0] function_return,
    input logic [4:0] register_a_index, //register_one from IR_Decode
    input logic [4:0] register_b_index, //register_two from IR_Decode
    input logic [4:0] write_register, //destination_register from IR_Decode
    input logic [31:0] link, //PC+8 to be stored in register in case of Jump and Link from PC block
    input logic [31:0] address, // PC from PC block
    input logic [31:0] write_data,
    output logic [31:0] register_a_data, 
    output logic [31:0] register_b_data
    );

    logic [31:0] regs [31:0];

    always_comb begin
        if (reset==1)begin
            register_a_data=0;
            register_b_data=0;
        end

        register_a_data = regs[register_a_index];
        register_b_data = regs[register_b_index];
    
    end

    always_ff @(posedge clk ) begin
        if (reset==1) begin
            for(int i=0;i<32;i=i+1) begin
                regs[i] <= 0;
            end     
        end
        if(write_enable==1) begin

            if(write_register != (0||2||31))begin
                regs[write_register] <= write_data;
            end
                
          regs[0] <= 0; 
          regs[2] <= function_return;   
          regs[31] <= link;
          
        end
    end

    endmodule