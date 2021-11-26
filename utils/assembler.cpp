#include <iostream>
#include <regex>
#include <string>
#include "opcodes.h"
#include "registers.h"


std::string &trim(std::string &str) {
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

int main() {
    std::string line;
    while (getline(std::cin, line)) {
        std::cout << convert_instruction_to_hex(line) << std::endl;
    }
}