module hazard_detector(
    input logic[6:0] instruction_code,
    output logic memory_hazard
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
    } instcode_t;

    always @(*) begin
        if (instruction_code == LB || instruction_code == LBU || instruction_code == LH || instruction_code == LHU
            || instruction_code == LW || instruction_code == LWL || instruction_code == LWR || instruction_code == SB
            || instruction_code == SH || instruction_code == SW)
            memory_hazard = 1;
        else
            memory_hazard = 0;
    end
endmodule