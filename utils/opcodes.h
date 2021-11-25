#ifndef CPU_CW_OPCODES_H
#define CPU_CW_OPCODES_H

class Opcodes {
public:
    const static int JR = 0b000000;
    const static int ADDU = 0b000000;
    const static int ADDIU = 0b001001;
    const static int LW = 0b100011;
    const static int SW = 0b101011;
};

#endif //CPU_CW_OPCODES_H

