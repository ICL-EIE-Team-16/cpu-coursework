#include <gtest/gtest.h>
#include <regex>

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

std::string &trim(std::string &str) {
    str.erase(0, str.find_first_not_of(' '));
    str.erase(str.find_last_not_of(' ') + 1);
    return str;
}

std::string decimal_to_8_char_hex(unsigned int num) {
    std::string result;
    char hex_chars[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

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

int register_name_to_index(const std::string& registerName) {
    if (registers.find(registerName) == registers.end()) {
        std::cerr << "Invalid register name provided: " << registerName << std::endl;
        return -1;
    } else {
        return registers[registerName];
    }
}

int convert_immediate_const_to_int(std::string immediateConst) {
    trim(immediateConst);

    if (immediateConst.substr(0, 2) == "0x") {
        return std::stoi(immediateConst, nullptr, 16);
    } else if (immediateConst.substr(0, 2) == "0b") {
        return std::stoi(immediateConst.substr(2), nullptr, 2);
    } else {
        return std::stoi(immediateConst);
    }
}

int covert_jr_instruction_to_num(const std::string& command) {
    int shiftedOpcode = Opcodes::JR << 25;

    std::string registerName = command.substr(command.find(' ') + 1);

    int shiftedRS = register_name_to_index(registerName) << 20;

    return (shiftedOpcode + shiftedRS + 0b1000);
}

int convert_addu_instruction_to_num(const std::string& command) {
    int code = Opcodes::ADDU << 25;
    std::regex rgx("ADDU (.+), (.+), (.+)");
    std::smatch matches;

    if (std::regex_search(command, matches, rgx)) {
        std::string rs, rt, rd;
        if (matches.size() == 4) {
            code += register_name_to_index(matches[1]) << 10;
            code += register_name_to_index(matches[2]) << 20;
            code += register_name_to_index(matches[3]) << 15;
            code += 0b100001;
        } else {
            std::cerr << "Invalid amount of arguments provided." << std::endl;
        }
    } else {
        std::cerr << "Invalid command passed as an argument." << std::endl;
    }

    return code;
}

int convert_addiu_instruction_to_num(const std::string& command) {
    int code = Opcodes::ADDIU << 25;
    std::regex rgx("ADDIU (.+), (.+), (.+)");
    std::smatch matches;

    if (std::regex_search(command, matches, rgx)) {
        std::string rs, rt, rd;
        if (matches.size() == 4) {
            code += register_name_to_index(matches[1]) << 15;
            code += register_name_to_index(matches[2]) << 20;
            code += convert_immediate_const_to_int(matches[3]);
        } else {
            std::cerr << "Invalid amount of arguments provided." << std::endl;
        }
    } else {
        std::cerr << "Invalid command passed as an argument." << std::endl;
    }

    return code;
}

int convert_ls_instruction_to_num(const std::string& command, int opcode) {
    int code = opcode << 25;
    std::regex rgx("L?S?W (.+), (.+)\\((.+)\\)");
    std::smatch matches;

    if (std::regex_search(command, matches, rgx)) {
        std::string rs, rt, rd;
        if (matches.size() == 4) {
            code += register_name_to_index(matches[3]) << 20;
            code += register_name_to_index(matches[1]) << 15;
            code += convert_immediate_const_to_int(matches[2]);
        } else {
            std::cerr << "Invalid amount of arguments provided." << std::endl;
        }
    } else {
        std::cerr << "Invalid command passed as an argument." << std::endl;
    }

    return code;
}

int convert_lw_instruction_to_num(const std::string& command) {
    return convert_ls_instruction_to_num(command, Opcodes::LW);
}

int convert_sw_instruction_to_num(const std::string& command) {
    return convert_ls_instruction_to_num(command, Opcodes::SW);
}

std::string convert_instruction_to_hex(const std::string& command) {
    int code = 0;
    std::string instruction = command.substr(0, command.find(' '));

    if (instruction == "JR") {
        code = covert_jr_instruction_to_num(command);
    } else if (instruction == "ADDU") {
        code = convert_addu_instruction_to_num(command);
    } else if (instruction == "ADDIU") {
        code = convert_addiu_instruction_to_num(command);
    } else if (instruction == "LW") {
        code = convert_lw_instruction_to_num(command);
    } else if (instruction == "SW") {
        code = convert_sw_instruction_to_num(command);
    }

    return decimal_to_8_char_hex(code);
}

TEST(Assembler, DecimalTo8CharHex) {
    EXPECT_EQ("00000000", decimal_to_8_char_hex(0));
    EXPECT_EQ("00000001", decimal_to_8_char_hex(1));
    EXPECT_EQ("0000000F", decimal_to_8_char_hex(15));
    EXPECT_EQ("FFFFFFFF", decimal_to_8_char_hex(4294967295));
}

TEST(Assembler, JRToHexAssembly) {
    EXPECT_EQ("01F00008", convert_instruction_to_hex("JR $ra"));
    EXPECT_EQ("01000008", convert_instruction_to_hex("JR $s0"));
    EXPECT_EQ("01100008", convert_instruction_to_hex("JR $s1"));
}

TEST(Assembler, ADDUToHexAssembly) {
    EXPECT_EQ("01194021", convert_instruction_to_hex("ADDU $s0, $s1, $s2"));
    EXPECT_EQ("00320821", convert_instruction_to_hex("ADDU $v0, $v1, $a0"));
}

TEST(Assembler, ADDIUToHexAssembly) {
    EXPECT_EQ("131800FF", convert_instruction_to_hex("ADDIU $s0, $s1, 0xff"));
    EXPECT_EQ("13288003", convert_instruction_to_hex("ADDIU $s1, $s2, 0b00011"));
    EXPECT_EQ("1308800B", convert_instruction_to_hex("ADDIU $s1, $s0, 11"));
}

TEST(Assembler, LWToHexAssembly) {
    EXPECT_EQ("4718000C", convert_instruction_to_hex("LW $s0, 12($s1)"));
    EXPECT_EQ("471900FC", convert_instruction_to_hex("LW $s2, 0xFC($s1)"));
    EXPECT_EQ("47190064", convert_instruction_to_hex("LW $s2, 0b1100100($s1)"));
}

TEST(Assembler, SWToHexAssembly) {
    EXPECT_EQ("5718000E", convert_instruction_to_hex("SW $s0, 14($s1)"));
    EXPECT_EQ("571900FD", convert_instruction_to_hex("SW $s2, 0xFD($s1)"));
    EXPECT_EQ("57190064", convert_instruction_to_hex("SW $s2, 0b1100100($s1)"));
}
