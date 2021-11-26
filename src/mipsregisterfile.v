

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

    logic [31:0] reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7,reg8,reg9,reg10,reg11,reg12,reg13,reg14,reg15,reg16,reg17,reg18,reg19,reg20,reg21,reg22,reg23,reg24,reg25,reg26,reg27,reg28,reg29,reg30,reg31;
    logic [31:0] regs [4:0];

    always_comb begin
        if (reset==1)begin
            register_a_data=0;
            register_b_data=0;
        end
    
        case (register_a_index)
        0: register_a_data=reg0 ;
        1:  register_a_data=reg1 ;
        2:  register_a_data=reg2 ;
        3:  register_a_data=reg3 ;
        4:  register_a_data=reg4 ;
        5:  register_a_data=reg5 ;
        6:  register_a_data=reg6 ;
        7:  register_a_data=reg7 ;
        8:  register_a_data=reg8 ;
        9:  register_a_data=reg9 ;
        10:  register_a_data=reg10 ;
        11:  register_a_data=reg11 ;
        12:  register_a_data=reg12 ;
        13:  register_a_data=reg13 ;
        14:  register_a_data=reg14 ;
        15:  register_a_data=reg15 ;
        16:  register_a_data=reg16 ;
        17:  register_a_data=reg17 ;
        18:  register_a_data=reg18 ;
        19:  register_a_data=reg19 ;
        20:  register_a_data=reg20 ;
        21:  register_a_data=reg21 ;
        22:  register_a_data=reg22 ;
        23:  register_a_data=reg23 ;
        24:  register_a_data=reg24 ;
        25:  register_a_data=reg25 ;
        26:  register_a_data=reg26 ;
        27:  register_a_data=reg27 ;
        28:  register_a_data=reg28 ;
        29:  register_a_data=reg29 ;
        30:  register_a_data=reg30 ;
        31:  register_a_data=reg31 ;
        endcase
        case (register_b_index)
        0:  register_b_data=reg0 ;
        1:  register_b_data=reg1 ;
        2:  register_b_data=reg2 ;
        3:  register_b_data=reg3 ;
        4:  register_b_data=reg4 ;
        5:  register_b_data=reg5 ;
        6:  register_b_data=reg6 ;
        7:  register_b_data=reg7 ;
        8:  register_b_data=reg8 ;
        9:  register_b_data=reg9 ;
        10:  register_b_data=reg10 ;
        11:  register_b_data=reg11 ;
        12:  register_b_data=reg12 ;
        13:  register_b_data=reg13 ;
        14:  register_b_data=reg14 ;
        15:  register_b_data=reg15 ;
        16:  register_b_data=reg16 ;
        17:  register_b_data=reg17 ;
        18:  register_b_data=reg18 ;
        19:  register_b_data=reg19 ;
        20:  register_b_data=reg20 ;
        21:  register_b_data=reg21 ;
        22:  register_b_data=reg22 ;
        23:  register_b_data=reg23 ;
        24:  register_b_data=reg24 ;
        25:  register_b_data=reg25 ;
        26:  register_b_data=reg26 ;
        27:  register_b_data=reg27 ;
        28:  register_b_data=reg28 ;
        29:  register_b_data=reg29 ;
        30:  register_b_data=reg30 ;
        31:  register_b_data=reg31 ;
        endcase
    end

    always_ff @(posedge clk ) begin
        if (reset==1) begin
            reg0 <= 0;
            reg1<=0;
            reg2<=0;
            reg3<=0;
            reg4<=0;
            reg5<=0;
            reg6<=0;
            reg7<=0;
            reg8<=0;
            reg9<=0;
            reg10<=0;
            reg11<=0;
            reg12<=0;
            reg13<=0;
            reg14<=0;
            reg15<=0;
            reg16<=0;
            reg17<=0;
            reg18<=0;
            reg19<=0;
            reg20<=0;
            reg21<=0;
            reg22<=0;
            reg23<=0;
            reg24<=0;
            reg25<=0;
            reg26<=0;
            reg27<=0;
            reg28<=0;
            reg29<=0;
            reg30<=0;
            reg31<=0;
        end
        if(write_enable==1) begin
            case(write_register)
                0:  reg0<=0 ; //should always stay 0
                1:  reg1<=write_data ;
               2: reg2 <= function_return;
                3:  reg3<=write_data ;
                4:  reg4<=write_data ;
                5: reg5<=write_data ;
                6:  reg6<=write_data ;
                7:  reg7<=write_data ;
                8:  reg8<=write_data ;
                9:  reg9<=write_data ;
                10:  reg10<=write_data ;
                11:  reg11<=write_data ;
                12:  reg12<=write_data ;
                13:  reg13<=write_data ;
                14:  reg14<=write_data ;
                15:  reg15<=write_data ;
                16:  reg16<=write_data ;
                17:  reg17<=write_data ;
                18:  reg18<=write_data ;
                19:  reg19<=write_data ;
                20:  reg20<=write_data ;
                21:  reg21<=write_data ;
                22:  reg22<=write_data ;
                23:  reg23<=write_data ;
                24:  reg24<=write_data ;
                25:  reg25<=write_data ;
                26:  reg26<=write_data ;
                27:  reg27<=write_data ;
                28:  reg28<=write_data ;
                29: reg29<=write_data ;
                30: reg30<=write_data ;
                31 : reg31 <= link;
            endcase
            reg31 <= link;
           reg2 <= function_return;
        end
    end

    endmodule