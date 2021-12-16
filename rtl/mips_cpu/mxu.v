// -------------------------------------------------------------------
// @author michal
// @copyright (C) 2021, <COMPANY>
//
// Created : 03. Dec 2021 12:14
//-------------------------------------------------------------------
module mxu(
    input logic waitrequest,
    input logic[31:0] mxu_reg_b_in,
    input logic[31:0] memin,
    input logic fetch,
    input logic exec1,
    input logic exec2,
    input logic[6:0] instruction_code_1,
    input logic[6:0] instruction_code_2,
    input logic[31:0] pc_address,
    input logic[31:0] alu_r,
    output logic[31:0] mem_address,
    output logic[31:0] dataout,
    output logic[31:0] memout,
    output logic read,
    output logic write,
    output logic[3:0] byteenable,
    output logic mem_halt
);

    typedef enum logic[6:0]{
        LB = 7'd42,
        LBU = 7'd43,
        LH = 7'd44,
        LHU = 7'd45,
        LW = 7'd47,
        LWL = 7'd48,
        LWR = 7'd49,
        SB = 7'd50,
        SH = 7'd51,
        SW = 7'd52
    } instruction_code_t;

// Address processing
    always @(*) begin
        if (instruction_code_1 == LB || instruction_code_1 == LBU || instruction_code_1 == LH || instruction_code_1 == LHU || instruction_code_1 == LW
            || instruction_code_1 == LWL || instruction_code_1 == LWR || instruction_code_1 == SB || instruction_code_1 == SW || instruction_code_1 == SH)
            mem_address = {alu_r[31:2], 2'b00};
        else
            mem_address = pc_address;
    end


//Read  signal
    always @(*) begin
        read = ~write || fetch;
    end


//Write signal
    always @(*) begin
        if (instruction_code_1 == SB || instruction_code_1 == SW || instruction_code_1 == SH)
            write = 1;
        else
            write = 0;
    end


//Memhalt signal
    always @(*) begin
        if ((read || write) && waitrequest)
            mem_halt = 1;
        else
            mem_halt = 0;
    end


//Decodememory i
    always @(*) begin
        if (instruction_code_2 == LW) begin
            dataout = memin;
        end
        else if (instruction_code_2 == LB) begin
            if (alu_r[1:0] == 0) begin
                dataout = {{24{memin[31]}}, memin[31:24]};
            end
            else if (alu_r[1:0] == 1) begin
                dataout = {{24{memin[23]}}, memin[23:16]};
            end
            else if (alu_r[1:0] == 2) begin
                dataout = {{24{memin[15]}}, memin[15:8]};
            end
            else if (alu_r[1:0] == 3) begin
                dataout = {{24{memin[7]}}, memin[7:0]};
            end
        end
        else if (instruction_code_2 == LBU) begin
            if (alu_r[1:0] == 0) begin
                dataout = {24'b0, memin[31:24]};
            end
            else if (alu_r[1:0] == 1) begin
                dataout = {24'b0, memin[23:16]};
            end
            else if (alu_r[1:0] == 2) begin
                dataout = {24'b0, memin[15:8]};
            end
            else if (alu_r[1:0] == 3) begin
                dataout = {24'b0, memin[7:0]};
            end
        end
        else if (instruction_code_2 == LH) begin
            if (alu_r[1] == 0) begin
                dataout = {{16{memin[31]}}, memin[31:16]};
            end
            else if (alu_r[1] == 1) begin
                dataout = {{16{memin[15]}}, memin[15:0]};
            end
        end
        else if (instruction_code_2 == LHU) begin
            if (alu_r[1] == 0) begin
                dataout = {16'b0, memin[31:16]};
            end
            else if (alu_r[1] == 1) begin
                dataout = {16'b0, memin[15:0]};
            end
        end
        else if (instruction_code_2 == LWL) begin
            if (alu_r[1:0] == 0) begin
                dataout = memin;
            end
            else if (alu_r[1:0] == 1) begin
                dataout = {memin[23:0], mxu_reg_b_in[7:0]};
            end
            else if (alu_r[1:0] == 2) begin
                dataout = {memin[15:0], mxu_reg_b_in[15:0]};
            end
            else if (alu_r[1:0] == 3) begin
                dataout = {memin[7:0], mxu_reg_b_in[23:0]};
            end
        end
        else if (instruction_code_2 == LWR) begin
            if (alu_r[1:0] == 0) begin
                dataout = mxu_reg_b_in;
            end
            else if (alu_r[1:0] == 1) begin
                dataout = {mxu_reg_b_in[31:8], memin[31:24]};
            end
            else if (alu_r[1:0] == 2) begin
                dataout = {mxu_reg_b_in[31:16], memin[31:16]};
            end
            else if (alu_r[1:0] == 3) begin
                dataout = {mxu_reg_b_in[31:24], memin[31:8]};
            end
        end
        else begin
            dataout = memin;
        end
    end

//Encode memory outputs
    always @(*) begin
        if (instruction_code_1 == SW) begin
            memout = mxu_reg_b_in;
        end
        else if (instruction_code_1 == SB) begin
            if (alu_r[1:0] == 0) begin
                memout = {mxu_reg_b_in[7:0], 24'b0};
            end
            else if (alu_r[1:0] == 1) begin
                memout = {8'b0, mxu_reg_b_in[7:0], 16'b0};
            end
            else if (alu_r[1:0] == 2) begin
                memout = {16'b0, mxu_reg_b_in[7:0], 8'b0};
            end
            else if (alu_r[1:0] == 3) begin
                memout = {24'b0, mxu_reg_b_in[7:0]};
            end
        end
        else if (instruction_code_1 == SH) begin
            if (alu_r[1] == 0) begin
                memout = {mxu_reg_b_in[15:0], 16'b0};
            end
            else begin
                memout = {16'b0, mxu_reg_b_in[15:0]};
            end
        end
        else begin
            memout = 0;
        end
    end

//BYTEENABLE SIGNAL
    always @(*) begin
        if (instruction_code_1 == SW || instruction_code_1 == LW) begin
            byteenable = 4'b1111;
        end

        else if (instruction_code_1 == SB || instruction_code_1 == LB || instruction_code_1 == LBU) begin
            if (alu_r[1:0] == 0) begin
                byteenable = 4'b0001;
            end
            else if (alu_r[1:0] == 1) begin
                byteenable = 4'b0010;
            end
            else if (alu_r[1:0] == 2) begin
                byteenable = 4'b0100;
            end
            else if (alu_r[1:0] == 3) begin
                byteenable = 4'b1000;
            end
        end
        else if (instruction_code_1 == SH || instruction_code_1 == LH || instruction_code_1 == LHU) begin
            if (alu_r[1] == 0) begin
                byteenable = 4'b0011;
            end
            else begin
                byteenable = 4'b1100;
            end
        end

        else if (instruction_code_1 == LWL) begin
            if (alu_r[1:0] == 0) begin
                byteenable = 4'b1111;
            end
            else if (alu_r[1:0] == 1) begin
                byteenable = 4'b1110;
            end
            else if (alu_r[1:0] == 2) begin
                byteenable = 4'b1100;
            end
            else if (alu_r[1:0] == 3) begin
                byteenable = 4'b1000;
            end
        end

        else if (instruction_code_1 == LWR) begin
            if (alu_r[1:0] == 0) begin
                byteenable = 4'b0000;
            end
            else if (alu_r[1:0] == 1) begin
                byteenable = 4'b0001;
            end
            else if (alu_r[1:0] == 2) begin
                byteenable = 4'b0011;
            end
            else if (alu_r[1:0] == 3) begin
                byteenable = 4'b0111;
            end
        end

        else if (read) begin
            byteenable = 4'b1111;
        end

        else begin
            byteenable = 4'b0;
        end
    end

endmodule