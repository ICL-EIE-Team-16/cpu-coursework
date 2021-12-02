#include <regex>
#include <vector>

#ifndef CPU_CW_OPCODES_H
#define CPU_CW_OPCODES_H

class Opcodes {
public:
    const static int ADDU = 0b000000;
    const static int ADDIU = 0b001001;
    const static int AND = 0b000000;
    const static int ANDI = 0b001100;
    const static int BEQ = 0b000100;
    const static int BGEZ = 0b000001;
    const static int BGEZAL = 0b000001;
    const static int BGTZ = 0b000111;
    const static int BLEZ = 0b000110;
    const static int BLTZ = 0b000001;
    const static int BLTZAL = 0b000001;
    const static int BNE = 0b000101;
    const static int DIV = 0b000000;
    const static int DIVU = 0b000000;
    const static int J = 0b000010;
    const static int JAL = 0b000011;
    const static int JALR = 0b000000;
    const static int JR = 0b000000;
    const static int LB = 0b100000;
    const static int LBU = 0b100100;
    const static int LH = 0b100001;
    const static int LHU = 0b100101;
    const static int LUI = 0b001111;
    const static int LW = 0b100011;
    const static int LWL = 0b100010;
    const static int LWR = 0b100110;
    const static int MFHI = 0b000000;
    const static int MFLO = 0b000000;
    const static int MTHI = 0b000000;
    const static int MTLO = 0b000000;
    const static int MULT = 0b000000;
    const static int MULTU = 0b000000;
    const static int OR = 0b000000;
    const static int ORI = 0b001101;
    const static int SB = 0b101000;
    const static int SH = 0b101001;
    const static int SLL = 0b000000;
    const static int SLLV = 0b000000;
    const static int SLT = 0b000000;
    const static int SLTI = 0b001010;
    const static int SLTIU = 0b001011;
    const static int SLTU = 0b000000;
    const static int SRA = 0b000000;
    const static int SRAV = 0b000000;
    const static int SRL = 0b000000;
    const static int SRLV = 0b000000;
    const static int SUBU = 0b000000;
    const static int SW = 0b101011;
    const static int XOR = 0b000000;
    const static int XORI = 0b001110;
};

#endif //CPU_CW_OPCODES_H

