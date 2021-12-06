#include <string>
#include <vector>

#ifndef CPU_CW_INSTRUCTION_PARSE_CONFIG_H
#define CPU_CW_INSTRUCTION_PARSE_CONFIG_H
class InstructionParseConfig {
private:
    std::regex regex;
    int opcode;
    int constantToAdd;
    std::vector<int> bitShifts;
public:
    InstructionParseConfig(std::regex regex, int opcode, int constantToAdd, std::vector<int> bitShifts) :
    regex(regex), opcode(opcode), constantToAdd(constantToAdd), bitShifts(bitShifts) {};

    std::regex getRegex() const { return regex; };

    int getOpcode() const { return this->opcode; };

    int getConstantToAdd() const { return this->constantToAdd; };

    std::vector<int> getBitShifts() const { return bitShifts; };
};
#endif //CPU_CW_INSTRUCTION_PARSE_CONFIG_H
