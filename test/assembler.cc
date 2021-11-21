#include <gtest/gtest.h>

// First instructions to test - JR, ADDU, ADDIU, LW, SW

class Opcodes {
public:
    const static int JR = 0b000000;
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

std::string decimal_to_8_char_hex(unsigned int num) {
    std::string result = "";
    char hex_chars[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

    while (num != 0) {
        int remainder = num % 16;
        num = num / 16;
        result = hex_chars[remainder] + result;
    }

    if (result.size() < 8) {
        result.insert(result.begin(), 8 - result.length(), '0');
    }

    return result;
}

std::string convert_instruction_to_hex(std::string command) {
    int code = 0;
    std::string instruction = command.substr(0, command.find(' '));

    if (instruction == "JR") {
        int shiftedOpcode = Opcodes::JR << 26;

        std::string registerName = command.substr(command.find(' ') + 1);
        int registerIndex = 0;

        if (registers.find(registerName) == registers.end()) {
            std::cerr << "Invalid register name provided" << std::endl;
        } else {
            registerIndex = registers[registerName];
        }
        int shiftedRS = registerIndex << 20;

        code = shiftedOpcode + shiftedRS + 0b1000;
    }

    return decimal_to_8_char_hex(code);
}

TEST(Assembler, DecimalTo8CharHex) {
    EXPECT_EQ("00000000", decimal_to_8_char_hex(0));
    EXPECT_EQ("00000001", decimal_to_8_char_hex(1));
    EXPECT_EQ("0000000F", decimal_to_8_char_hex(15));
    EXPECT_EQ("FFFFFFFF", decimal_to_8_char_hex(4294967295));
}

TEST(Assemlber, JRToHexAssembly) {
    EXPECT_EQ("01F00008", convert_instruction_to_hex("JR $ra"));
    EXPECT_EQ("01000008", convert_instruction_to_hex("JR $s0"));
    EXPECT_EQ("01100008", convert_instruction_to_hex("JR $s1"));
}