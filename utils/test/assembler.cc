#include <gtest/gtest.h>
#include <regex>
#include <vector>
#include <map>

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

class Opcodes {
public:
    const static int JR = 0b000000;
    const static int ADDU = 0b000000;
    const static int ADDIU = 0b001001;
    const static int LW = 0b100011;
    const static int SW = 0b101011;
};

std::map<std::string, int> registers{
        {"$zero", 0},
        {"$at",   1},
        {"$v0",   2},
        {"$v1",   3},
        {"$a0",   4},
        {"$a1",   5},
        {"$a2",   6},
        {"$a3",   7},
        {"$t0",   8},
        {"$t1",   9},
        {"$t2",   10},
        {"$t3",   11},
        {"$t4",   12},
        {"$t5",   13},
        {"$t6",   14},
        {"$t7",   15},
        {"$s0",   16},
        {"$s1",   17},
        {"$s2",   18},
        {"$s3",   19},
        {"$s4",   20},
        {"$s5",   21},
        {"$s6",   22},
        {"$s7",   23},
        {"$t8",   24},
        {"$t9",   25},
        {"$k0",   26},
        {"$k1",   27},
        {"$gp",   28},
        {"$sp",   29},
        {"$s8",   30},
        {"$ra",   31},
};

std::string trim(std::string str) {
    str.erase(0, str.find_first_not_of(' '));
    str.erase(str.find_last_not_of(' ') + 1);
    return str;
}

std::string decimal_to_8_char_hex(unsigned int num) {
    std::string result;
    char hex_chars[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    while (num != 0) {
        unsigned int remainder = num % 16;
        num = num / 16;
        result = hex_chars[remainder] + result;
    }

    if (result.size() < 8) {
        result.insert(result.begin(), 8 - result.length(), '0');
    }

    return result;
}

int register_name_to_index(const std::string &registerName) {
    if (registers.find(registerName) == registers.end()) {
        std::cerr << "Invalid register name provided: " << registerName << std::endl;
        return -1;
    } else {
        return registers[registerName];
    }
}

int convert_immediate_const_to_int(std::string immediateConst) {
    immediateConst = trim(immediateConst);

    if (immediateConst.substr(0, 2) == "0x") {
        return std::stoi(immediateConst, nullptr, 16);
    } else if (immediateConst.substr(0, 2) == "0b") {
        return std::stoi(immediateConst.substr(2), nullptr, 2);
    } else {
        return std::stoi(immediateConst);
    }
}

std::map<std::string, InstructionParseConfig> initializeConfigMap() {
    std::map<std::string, InstructionParseConfig> configs;

    std::regex adduRegex("ADDU (.+), (.+), (.+)");
    std::vector<int> adduShifts{10, 20, 15};
    InstructionParseConfig ADDU_CONFIG(adduRegex, Opcodes::ADDU, 0b100001, adduShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ADDU", ADDU_CONFIG));

    std::regex adduiRegex("ADDIU (.+), (.+), (.+)");
    std::vector<int> adduiShifts{15, 20, -1};
    InstructionParseConfig ADDIU_CONFIG(adduiRegex, Opcodes::ADDIU, 0, adduiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ADDIU", ADDIU_CONFIG));

    std::regex jrRegex("JR (.+)");
    std::vector<int> jrShifts{20};
    InstructionParseConfig JR_CONFIG(jrRegex, Opcodes::JR, 0b1000, jrShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("JR", JR_CONFIG));

    std::regex lwRegex("LW (.+), (.+)\\((.+)\\)");
    std::vector<int> lwShifts{15, -1, 20};
    InstructionParseConfig LW_CONFIG(lwRegex, Opcodes::LW, 0, lwShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LW", LW_CONFIG));

    std::regex swRegex("SW (.+), (.+)\\((.+)\\)");
    std::vector<int> swShifts{15, -1, 20};
    InstructionParseConfig SW_CONFIG(swRegex, Opcodes::SW, 0, swShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SW", SW_CONFIG));

    return configs;
}

std::string convert_instruction_to_hex(const std::string &command,
                                       const std::map<std::string, InstructionParseConfig> configs) {
    int code = 0;
    std::string trimmedCommand = trim(command);
    std::string instrName = trimmedCommand.substr(0, trimmedCommand.find(" "));
    InstructionParseConfig config = configs.find(instrName)->second;
    code += (config.getOpcode() << 25);

    std::smatch matches;
    if (std::regex_search(command, matches, config.getRegex())) {
        for (int i = 1; i < matches.size(); i++) {
            int bitShift = config.getBitShifts()[i - 1];
            if (bitShift == -1) {
                code += convert_immediate_const_to_int(matches[i]);
            } else {
                code += register_name_to_index(matches[i]) << bitShift;
            }
        }
    } else {
        std::cerr << "Invalid command passed as an argument." << std::endl;
    }

    code += config.getConstantToAdd();

    return decimal_to_8_char_hex(code);
}

TEST(Assembler, DecimalTo8CharHex) {
    EXPECT_EQ("00000000", decimal_to_8_char_hex(0));
    EXPECT_EQ("00000001", decimal_to_8_char_hex(1));
    EXPECT_EQ("0000000f", decimal_to_8_char_hex(15));
    EXPECT_EQ("ffffffff", decimal_to_8_char_hex(4294967295));
}

TEST(Assembler, ADDUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("01194021", convert_instruction_to_hex("ADDU $s0, $s1, $s2", configs));
    EXPECT_EQ("00320821", convert_instruction_to_hex("ADDU $v0, $v1, $a0", configs));
}

TEST(Assembler, ADDUIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("131800ff", convert_instruction_to_hex("ADDIU $s0, $s1, 0xff", configs));
    EXPECT_EQ("13288003", convert_instruction_to_hex("ADDIU $s1, $s2, 0b00011", configs));
    EXPECT_EQ("1308800b", convert_instruction_to_hex("ADDIU $s1, $s0, 11", configs));
}

TEST(Assembler, JRToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("01f00008", convert_instruction_to_hex("JR $ra", configs));
    EXPECT_EQ("01000008", convert_instruction_to_hex("JR $s0", configs));
    EXPECT_EQ("01100008", convert_instruction_to_hex("JR $s1", configs));
}

TEST(Assembler, LWToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("4718000c", convert_instruction_to_hex("LW $s0, 12($s1)", configs));
    EXPECT_EQ("471900fc", convert_instruction_to_hex("LW $s2, 0xFC($s1)", configs));
    EXPECT_EQ("47190064", convert_instruction_to_hex("LW $s2, 0b1100100($s1)", configs));
}

TEST(Assembler, SWToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("5718000e", convert_instruction_to_hex("SW $s0, 14($s1)", configs));
    EXPECT_EQ("571900fd", convert_instruction_to_hex("SW $s2, 0xFD($s1)", configs));
    EXPECT_EQ("57190064", convert_instruction_to_hex("SW $s2, 0b1100100($s1)", configs));
}