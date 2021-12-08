// -------------------------------------------------------------------
// @author michal
// @copyright (C) 2021, <COMPANY>
//
// Created : 03. Dec 2021 12:14
//-------------------------------------------------------------------
module mxu (
input logic waitrequest,
input logic[31:0] regdatain,
input logic[31:0] memin,
input logic fetch,
input logic exec1,
input logic exec2,
input logic[6:0] instruction_code,
input logic[31:0] pc_address,
input logic[31:0] alu_r,
output logic[31:0] mem_address,
output logic[31:0] dataout,
output logic [31:0] memout,
output logic read,
output logic write,
output logic[3:0] byteenable,
output logic mem_halt
);

typedef enum logic[6:0] {
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
    } instruction_code_t;

always_comb begin
    byteenable = 15;
    dataout = memin;
    memout = regdatain;


    if (fetch)
        mem_address = pc_address;
    else
        mem_address = alu_r;
end


//Read  signal
always_comb begin
    if (fetch)
        read = 1;
    else if (exec1) begin
        if (instruction_code == LB || instruction_code == LBU || instruction_code == LH || instruction_code == LHU)
            read = 1; //This should be one but it's off for debugging
        else if (instruction_code == LUI || instruction_code == LW || instruction_code == LWL || instruction_code == LWR)
            read = 1; //This should be one but it's off for debugging
        else
            read = 0;
    end
    else
        read = 0;
end


//Write signal
always_comb begin
    if (exec1) begin
        if (instruction_code == SB || instruction_code == SW || instruction_code == SH)
            write = 1;
    end
    else
        write = 0;
end


//Memhalt signal
always_comb begin
    if ((read || write)&& waitrequest)
        mem_halt = 1;
    else
        mem_halt = 0;
end

endmodule