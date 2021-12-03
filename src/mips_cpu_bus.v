module mips_cpu_bus(
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

logic fetch, exec1, exec2;
logic[31:0] databus;
logic[6:0] instcode;

    statemachine sm(.reset(reset), .fetch(fetch), .exec1(exec1), .exec2(exec2));
    mxu mainmxu(.din(databus), .memin(readdata), .fetch(fetch), .ex1(exec1), .ex2(exec2), .in_instcode(instcode), .dataout(), .memout(writedata), .read(read), .write(write), .byteenable(byteenable));
    alu mainalu(.a(), .b(), .op(), .r());
    mipsregisterfile regfile(.clk(clk), .reset(reset), .write_enable(), .f);

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
endmodule