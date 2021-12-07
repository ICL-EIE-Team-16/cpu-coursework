#include <iostream>
#include <regex>
#include <string>
#include <vector>
#include "opcodes.h"
#include "registers.h"
#include "utils.h"
#include "instruction-parse-config.h"

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

unsigned int convert_immediate_const_to_int(std::string immediateConst) {
    immediateConst = trim(immediateConst);

    if (immediateConst.substr(0, 2) == "0x") {
        return std::stoul(immediateConst, nullptr, 16);
    } else if (immediateConst.substr(0, 2) == "0b") {
        return std::stoul(immediateConst.substr(2), nullptr, 2);
    } else {
        return std::stoul(immediateConst);
    }
}

bool is_line_comment(const std::string &command) {
    std::regex commentLineRegex("^\\#.*");
    std::smatch matches;
    return std::regex_search(command, matches, commentLineRegex);
}

std::map<std::string, InstructionParseConfig> initializeConfigMap() {
    std::map<std::string, InstructionParseConfig> configs;

    std::regex andRegex("AND (.+), (.+), (.+)");
    std::vector<int> andShifts{11, 21, 16};
    InstructionParseConfig AND_CONFIG(andRegex, Opcodes::AND, 0b100100, andShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("AND", AND_CONFIG));

    std::regex andiRegex("ANDI (.+), (.+), (.+)");
    std::vector<int> andiShifts{16, 21, -1};
    InstructionParseConfig ANDI_CONFIG(andiRegex, Opcodes::ANDI, 0, andiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ANDI", ANDI_CONFIG));

    std::regex adduRegex("ADDU (.+), (.+), (.+)");
    std::vector<int> adduShifts{11, 21, 16};
    InstructionParseConfig ADDU_CONFIG(adduRegex, Opcodes::ADDU, 0b100001, adduShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ADDU", ADDU_CONFIG));

    std::regex adduiRegex("ADDIU (.+), (.+), (.+)");
    std::vector<int> adduiShifts{16, 21, -1};
    InstructionParseConfig ADDIU_CONFIG(adduiRegex, Opcodes::ADDIU, 0, adduiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ADDIU", ADDIU_CONFIG));

    std::regex beqRegex("BEQ (.+), (.+), (.+)");
    std::vector<int> beqShifts{21, 16, -1};
    InstructionParseConfig BEQ_CONFIG(beqRegex, Opcodes::BEQ, 0, beqShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BEQ", BEQ_CONFIG));

    std::regex bgezRegex("BGEZ (.+), (.+)");
    std::vector<int> bgezShifts{21, -1};
    InstructionParseConfig BGEZ_CONFIG(bgezRegex, Opcodes::BGEZ, 0b00001 << 16, bgezShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BGEZ", BGEZ_CONFIG));

    std::regex bgezalRegex("BGEZAL (.+), (.+)");
    std::vector<int> bgezalShifts{21, -1};
    InstructionParseConfig BGEZAL_CONFIG(bgezalRegex, Opcodes::BGEZAL, 0b10001 << 16, bgezalShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BGEZAL", BGEZAL_CONFIG));

    std::regex bgtzRegex("BGTZ (.+), (.+)");
    std::vector<int> bgtzShifts{21, -1};
    InstructionParseConfig BGTZ_CONFIG(bgtzRegex, Opcodes::BGTZ, 0, bgtzShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BGTZ", BGTZ_CONFIG));

    std::regex blezRegex("BLEZ (.+), (.+)");
    std::vector<int> blezShifts{21, -1};
    InstructionParseConfig BLEZ_CONFIG(blezRegex, Opcodes::BLEZ, 0, blezShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BLEZ", BLEZ_CONFIG));

    std::regex bltzRegex("BLTZ (.+), (.+)");
    std::vector<int> bltzShifts{21, -1};
    InstructionParseConfig BLTZ_CONFIG(bltzRegex, Opcodes::BLTZ, 0, bltzShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BLTZ", BLTZ_CONFIG));

    std::regex bltzalRegex("BLTZAL (.+), (.+)");
    std::vector<int> bltzalShifts{21, -1};
    InstructionParseConfig BLTZAL_CONFIG(bltzalRegex, Opcodes::BLTZAL, 0b10000 << 16, bltzalShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BLTZAL", BLTZAL_CONFIG));

    std::regex bneRegex("BNE (.+), (.+), (.+)");
    std::vector<int> bneShifts{21, 16, -1};
    InstructionParseConfig BNE_CONFIG(bneRegex, Opcodes::BNE, 0, bneShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("BNE", BNE_CONFIG));

    std::regex divRegex("DIV (.+), (.+)");
    std::vector<int> divShifts{21, 16};
    InstructionParseConfig DIV_CONFIG(divRegex, Opcodes::DIV, 0b11010, divShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("DIV", DIV_CONFIG));

    std::regex divuRegex("DIVU (.+), (.+)");
    std::vector<int> divuShifts{21, 16};
    InstructionParseConfig DIVU_CONFIG(divuRegex, Opcodes::DIVU, 0b11011, divuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("DIVU", DIVU_CONFIG));

    std::regex jRegex("J (.+)");
    std::vector<int> jShifts{-1};
    InstructionParseConfig J_CONFIG(jRegex, Opcodes::J, 0, jShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("J", J_CONFIG));

    std::regex jalRegex("JAL (.+)");
    std::vector<int> jalShifts{-1};
    InstructionParseConfig JAL_CONFIG(jalRegex, Opcodes::JAL, 0, jalShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("JAL", JAL_CONFIG));

    std::regex jalrRegex("JALR (.+), (.+)");
    std::vector<int> jalrShifts{11, 21};
    InstructionParseConfig JALR_CONFIG(jalrRegex, Opcodes::JALR, 0b1001, jalrShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("JALR", JALR_CONFIG));

    std::regex jrRegex("JR (.+)");
    std::vector<int> jrShifts{21};
    InstructionParseConfig JR_CONFIG(jrRegex, Opcodes::JR, 0b1000, jrShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("JR", JR_CONFIG));

    std::regex lbRegex("LB (.+), (.+)\\((.+)\\)");
    std::vector<int> lbShifts{16, -1, 21};
    InstructionParseConfig LB_CONFIG(lbRegex, Opcodes::LB, 0, lbShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LB", LB_CONFIG));

    std::regex lbuRegex("LBU (.+), (.+)\\((.+)\\)");
    std::vector<int> lbuShifts{16, -1, 21};
    InstructionParseConfig LBU_CONFIG(lbuRegex, Opcodes::LBU, 0, lbuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LBU", LBU_CONFIG));

    std::regex lhRegex("LH (.+), (.+)\\((.+)\\)");
    std::vector<int> lhShifts{16, -1, 21};
    InstructionParseConfig LH_CONFIG(lhRegex, Opcodes::LH, 0, lhShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LH", LH_CONFIG));

    std::regex lhuRegex("LHU (.+), (.+)\\((.+)\\)");
    std::vector<int> lhuShifts{16, -1, 21};
    InstructionParseConfig LHU_CONFIG(lhuRegex, Opcodes::LHU, 0, lhuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LHU", LHU_CONFIG));

    std::regex luiRegex("LUI (.+), (.+)");
    std::vector<int> luiShifts{16, -1};
    InstructionParseConfig LUI_CONFIG(luiRegex, Opcodes::LUI, 0, luiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LUI", LUI_CONFIG));

    std::regex lwRegex("LW (.+), (.+)\\((.+)\\)");
    std::vector<int> lwShifts{16, -1, 21};
    InstructionParseConfig LW_CONFIG(lwRegex, Opcodes::LW, 0, lwShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LW", LW_CONFIG));

    std::regex lwlRegex("LWL (.+), (.+)\\((.+)\\)");
    std::vector<int> lwlShifts{16, -1, 21};
    InstructionParseConfig LWL_CONFIG(lwlRegex, Opcodes::LWL, 0, lwlShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LWL", LWL_CONFIG));

    std::regex lwrRegex("LWR (.+), (.+)\\((.+)\\)");
    std::vector<int> lwrShifts{16, -1, 21};
    InstructionParseConfig LWR_CONFIG(lwrRegex, Opcodes::LWR, 0, lwrShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("LWR", LWR_CONFIG));

    std::regex mfhiRegex("MFHI (.+)");
    std::vector<int> mfhiShifts{11};
    InstructionParseConfig MFHI_CONFIG(mfhiRegex, Opcodes::MFHI, 0b010000, mfhiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MFHI", MFHI_CONFIG));

    std::regex mfloRegex("MFLO (.+)");
    std::vector<int> mfloShifts{11};
    InstructionParseConfig MFLO_CONFIG(mfloRegex, Opcodes::MFLO, 0b010010, mfloShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MFLO", MFLO_CONFIG));

    std::regex mthiRegex("MTHI (.+)");
    std::vector<int> mthiShifts{21};
    InstructionParseConfig MTHI_CONFIG(mthiRegex, Opcodes::MTHI, 0b010001, mthiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MTHI", MTHI_CONFIG));

    std::regex mtloRegex("MTLO (.+)");
    std::vector<int> mtloShifts{21};
    InstructionParseConfig MTLO_CONFIG(mtloRegex, Opcodes::MTLO, 0b010011, mtloShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MTLO", MTLO_CONFIG));

    std::regex multRegex("MULT (.+), (.+)");
    std::vector<int> multShifts{21, 16};
    InstructionParseConfig MULT_CONFIG(multRegex, Opcodes::MULT, 0b011000, multShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MULT", MULT_CONFIG));

    std::regex multuRegex("MULTU[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> multuShifts{21, 16};
    InstructionParseConfig MULTU_CONFIG(multuRegex, Opcodes::MULTU, 0b011001, multuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("MULTU", MULTU_CONFIG));

    std::regex orRegex("OR[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> orShifts{11, 21, 16};
    InstructionParseConfig OR_CONFIG(orRegex, Opcodes::OR, 0b100101, orShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("OR", OR_CONFIG));

    std::regex oriRegex("ORI[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> oriShifts{16, 21, -1};
    InstructionParseConfig ORI_CONFIG(oriRegex, Opcodes::ORI, 0, oriShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("ORI", ORI_CONFIG));

    std::regex sbRegex("SB[\\s?]+(\\S+),[\\s?]+(\\S+)\\((\\S+)\\)");
    std::vector<int> sbShifts{16, -1, 21};
    InstructionParseConfig SB_CONFIG(sbRegex, Opcodes::SB, 0, sbShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SB", SB_CONFIG));

    std::regex shRegex("SH[\\s?]+(\\S+),[\\s?]+(\\S+)\\((\\S+)\\)");
    std::vector<int> shShifts{16, -1, 21};
    InstructionParseConfig SH_CONFIG(shRegex, Opcodes::SH, 0, shShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SH", SH_CONFIG));

    std::regex sllRegex("SLL[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sllShifts{11, 16, -6};
    InstructionParseConfig SLL_CONFIG(sllRegex, Opcodes::SLL, 0, sllShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLL", SLL_CONFIG));

    std::regex sllvRegex("SLLV[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sllvShifts{11, 16, 21};
    InstructionParseConfig SLLV_CONFIG(sllvRegex, Opcodes::SLLV, 0b000100, sllvShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLLV", SLLV_CONFIG));

    std::regex sltRegex("SLT[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sltShifts{11, 21, 16};
    InstructionParseConfig SLT_CONFIG(sltRegex, Opcodes::SLLV, 0b101010, sltShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLT", SLT_CONFIG));

    std::regex sltiRegex("SLTI[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sltiShifts{16, 21, -1};
    InstructionParseConfig SLTI_CONFIG(sltiRegex, Opcodes::SLTI, 0, sltiShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLTI", SLTI_CONFIG));

    std::regex sltiuRegex("SLTIU[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sltiuShifts{16, 21, -1};
    InstructionParseConfig SLTIU_CONFIG(sltiuRegex, Opcodes::SLTIU, 0, sltiuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLTIU", SLTIU_CONFIG));

    std::regex sltuRegex("SLTU[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sltuShifts{11, 21, 16};
    InstructionParseConfig SLTU_CONFIG(sltuRegex, Opcodes::SLTU, 0b101011, sltuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SLTU", SLTU_CONFIG));

    std::regex sraRegex("SRA[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sraShifts{11, 16, -6};
    InstructionParseConfig SRA_CONFIG(sraRegex, Opcodes::SRA, 0b000011, sraShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRA", SRA_CONFIG));

    std::regex sravRegex("SRAV[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sravShifts{11, 16, 21};
    InstructionParseConfig SRAV_CONFIG(sravRegex, Opcodes::SRAV, 0b000111, sravShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRAV", SRAV_CONFIG));

    std::regex srlRegex("SRL[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> srlShifts{11, 16, -6};
    InstructionParseConfig SRL_CONFIG(srlRegex, Opcodes::SRL, 0b000010, srlShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRL", SRL_CONFIG));

    std::regex srlvRegex("SRLV[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> srlvShifts{11, 16, 21};
    InstructionParseConfig SRLV_CONFIG(srlvRegex, Opcodes::SRLV, 0b000110, srlvShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRLV", SRLV_CONFIG));

    std::regex subuRegex("SUBU[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> subuShifts{11, 21, 16};
    InstructionParseConfig SUBU_CONFIG(subuRegex, Opcodes::SUBU, 0b100011, subuShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SUBU", SUBU_CONFIG));

    std::regex swRegex("SW (.+), (.+)\\((.+)\\)");
    std::vector<int> swShifts{16, -1, 21};
    InstructionParseConfig SW_CONFIG(swRegex, Opcodes::SW, 0, swShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SW", SW_CONFIG));

    std::regex xorRegex("XOR[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> xorShifts{11, 21, 16};
    InstructionParseConfig XOR_CONFIG(xorRegex, Opcodes::XOR, 0b100110, xorShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("XOR", XOR_CONFIG));

    std::regex xoriRegex("XORI[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> xoriShifts{16, 21, -1};
    InstructionParseConfig XORI_CONFIG(xoriRegex, Opcodes::XORI, 0, xoriShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("XORI", XORI_CONFIG));

    return configs;
}

std::string convert_instruction_to_hex(const std::string &command,
                                       const std::map<std::string, InstructionParseConfig> configs) {
    std::string trimmedCommand = trim(command);
    unsigned int code = 0;
    std::string instrName = trimmedCommand.substr(0, trimmedCommand.find(" "));
    auto it = configs.find(instrName);

    if (it != configs.end()) {
        InstructionParseConfig config = it->second;
        code += (config.getOpcode() << 26);

        std::smatch matches;
        if (std::regex_search(command, matches, config.getRegex())) {
            for (int i = 1; i < matches.size(); i++) {
                int bitShift = config.getBitShifts()[i - 1];
                if (bitShift < 0) {
                    int number = convert_immediate_const_to_int(matches[i]);
                    if (bitShift == -1) {
                        code += number;
                    } else {
                        code += number << (-1 * bitShift);
                    }
                } else {
                    code += register_name_to_index(matches[i]) << bitShift;
                }
            }
        } else if (instrName == "JALR" && std::regex_search(command, matches, std::regex("JALR (.+)"))) {
            code += register_name_to_index(matches[1]) << config.getBitShifts()[1];
            code += 31 << config.getBitShifts()[0];
        } else {
            std::cerr << "Invalid instruction pattern passed as an argument." << std::endl;
        }

        code += config.getConstantToAdd();
    } else {
        std::cerr << "Invalid instruction passed as an argument." << std::endl;
    }

    return decimal_to_8_char_hex(code);
}

std::map<int, std::string> convert_lines_to_ram_content(std::vector<std::string> &lines) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    std::map<int, std::string> result;
    std::vector<std::string> linesWithoutComments;

    std::copy_if(lines.begin(), lines.end(), std::back_inserter(linesWithoutComments),
                 [](std::string line) { return !is_line_comment(line); });

    std::regex dataLineRegex("0[xX]([\\da-fA-F]+):\\s*(\\S*)");

    int instrAddress = 0;
    for (int i = 0; i < linesWithoutComments.size(); i++) {
        std::string line = linesWithoutComments[i];
        std::smatch dataMatches;
        if (std::regex_search(line, dataMatches, dataLineRegex)) {
            std::string addressWithoutBase = dataMatches[1];
            std::string addressWithBase = "0x" + addressWithoutBase;
            int address = convert_immediate_const_to_int(addressWithBase);
            std::string data = decimal_to_8_char_hex(convert_immediate_const_to_int(dataMatches[2]));
            result.insert(std::pair<int, std::string>(address, data));
        } else {
            result.insert(std::pair<int, std::string>(instrAddress, convert_instruction_to_hex(line, configs)));
            instrAddress += 4;
        }
    }

    return result;
}

std::string generate_n_lines_of_zeroes(int n) {
    std::string result = "";
    for (int i = 0; i < n; i++) {
        result += "00000000\n";
    }
    return result;
}

std::string convert_ram_content_to_string(std::map<int, std::string>& ramContent) {
    std::string result = "";
    int lastAddress = -1;
    std::map<int, std::string>::iterator it;

    for (it = ramContent.begin(); it != ramContent.end(); it++)
    {
        if (it->first - 4 == lastAddress) {
            result += it->second + "\n";
        } else {
            result += generate_n_lines_of_zeroes((it->first - lastAddress - 1) / 4);
            result += it->second + "\n";
        }
        lastAddress = it->first;
    }

    return result;
}

int main() {
    std::string line;
    std::vector<std::string> lines;

    while (getline(std::cin, line)) {
        lines.push_back(line);
    }

    std::map<int, std::string> ramContent = convert_lines_to_ram_content(lines);
    std::cout << convert_ram_content_to_string(ramContent);
}