// -------------------------------------------------------------------
// @author michal
// @copyright (C) 2021, <COMPANY>
//
// Created : 03. Dec 2021 12:14
//-------------------------------------------------------------------
module mxu (
input logic[31:0] datain,
input logic[31:0] memin,
input logic fetch,
input logic ex1,
input logic ex2,
input logic[6:0] in_instcode,
output logic[31:0] dataout,
output logic [31:0] memout,
output logic read,
output logic write,
output logic[3:0] byteenable
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
    } instcode;

assign byteenable = 15;
assign dataout = memin;
assign memout = datain;


//Read  signal
always_comb begin
    if (fetch)
        read = 1;
    else if (ex1) begin
        if (instcode == LB || instcode == LBU || instcode == LH || instcode == LHU || instcode == LUI || instcode == LW || instcode == LWL || instcode == LWR)
            read = 1;
    end
    else
        read = 0;
end


//Write signal
always_comb begin
    if (ex1) begin
        if (instcode == SB || instcode == SW)
            write = 1;
    end
    else
        write = 0;
end

endmodule