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
    alu mainalu(.a(), .b(), .sa(), .op(), .zero(), .positive(), .negative(), .r());

endmodule