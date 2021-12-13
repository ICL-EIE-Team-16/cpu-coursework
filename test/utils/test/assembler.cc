#include <gtest/gtest.h>
#include <bitset>
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

std::map<std::string, int> registers{
        {"zero", 0},
        {"0", 0},
        {"at",   1},
        {"v0",   2},
        {"v1",   3},
        {"a0",   4},
        {"a1",   5},
        {"a2",   6},
        {"a3",   7},
        {"t0",   8},
        {"t1",   9},
        {"t2",   10},
        {"t3",   11},
        {"t4",   12},
        {"t5",   13},
        {"t6",   14},
        {"t7",   15},
        {"s0",   16},
        {"s1",   17},
        {"s2",   18},
        {"s3",   19},
        {"s4",   20},
        {"s5",   21},
        {"s6",   22},
        {"s7",   23},
        {"t8",   24},
        {"t9",   25},
        {"k0",   26},
        {"k1",   27},
        {"gp",   28},
        {"sp",   29},
        {"s8",   30},
        {"ra",   31},
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
    std::regex registerReg("\\$?(\\S+)");
    std::smatch matches;
    std::string registerNameParsed = "";

    if (std::regex_search(registerName, matches, registerReg)) {
        registerNameParsed = matches[1];
    }

    if (registers.find(registerNameParsed) == registers.end()) {
        std::cerr << "Invalid register name provided: " << registerName << std::endl;
        return -1;
    } else {
        return registers[registerNameParsed];
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
    std::vector<int> sraShifts{11, 16, 6};
    InstructionParseConfig SRA_CONFIG(sraRegex, Opcodes::SRA, 0b000011, sraShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRA", SRA_CONFIG));

    std::regex sravRegex("SRAV[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> sravShifts{11, 16, 21};
    InstructionParseConfig SRAV_CONFIG(sravRegex, Opcodes::SRAV, 0b000111, sravShifts);
    configs.insert(std::pair<std::string, InstructionParseConfig>("SRAV", SRAV_CONFIG));

    std::regex srlRegex("SRL[\\s?]+(\\S+),[\\s?]+(\\S+),[\\s?]+(\\S+)");
    std::vector<int> srlShifts{11, 16, 6};
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
    unsigned int code = 0;
    std::string trimmedCommand = trim(command);
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

TEST(Assembler, DecimalTo8CharHex) {
    EXPECT_EQ("00000000", decimal_to_8_char_hex(0));
    EXPECT_EQ("00000001", decimal_to_8_char_hex(1));
    EXPECT_EQ("0000000f", decimal_to_8_char_hex(15));
    EXPECT_EQ("ffffffff", decimal_to_8_char_hex(4294967295));
    EXPECT_EQ("0000ffff", decimal_to_8_char_hex(convert_immediate_const_to_int("0b1111111111111111")));
    EXPECT_EQ("ffffffff", decimal_to_8_char_hex(convert_immediate_const_to_int("0xFFFFFFFF")));
}

TEST(Assembler, ADDUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02328021", convert_instruction_to_hex("ADDU $s0, $s1, $s2", configs));
    EXPECT_EQ("00641021", convert_instruction_to_hex("ADDU $v0, $v1, $a0", configs));
    EXPECT_EQ("02321021", convert_instruction_to_hex("ADDU $v0, $s1, $s2", configs));
}

TEST(Assembler, ADDUIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("263000ff", convert_instruction_to_hex("ADDIU $s0, $s1, 0xff", configs));
    EXPECT_EQ("26510003", convert_instruction_to_hex("ADDIU $s1, $s2, 0b00011", configs));
    EXPECT_EQ("2611000b", convert_instruction_to_hex("ADDIU $s1, $s0, 11", configs));
}

TEST(Assembler, ANDToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02508824", convert_instruction_to_hex("AND $s1, $s2, $s0", configs));
    EXPECT_EQ("02328024", convert_instruction_to_hex("AND $s0, $s1, $s2", configs));
}

TEST(Assembler, ANDIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("3251ffff", convert_instruction_to_hex("ANDI $s1, $s2, 0b1111111111111111", configs));
    EXPECT_EQ("3230000a", convert_instruction_to_hex("ANDI $s0, $s1, 10", configs));
    EXPECT_EQ("32320010", convert_instruction_to_hex("ANDI $s2, $s1, 0x10", configs));
}

TEST(Assembler, BEQToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("1230000f", convert_instruction_to_hex("BEQ $s1, $s0, 0b1111", configs));
    EXPECT_EQ("1043ffab", convert_instruction_to_hex("BEQ $v0, $v1, 0xffab", configs));
    EXPECT_EQ("12511234", convert_instruction_to_hex("BEQ $s2, $s1, 0x1234", configs));
    EXPECT_EQ("1251000c", convert_instruction_to_hex("BEQ $s2, $s1, 12", configs));
}

TEST(Assembler, BGEZToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("064100ff", convert_instruction_to_hex("BGEZ $s2, 0b11111111", configs));
    EXPECT_EQ("06011111", convert_instruction_to_hex("BGEZ $s0, 0x1111", configs));
    EXPECT_EQ("0621006e", convert_instruction_to_hex("BGEZ $s1, 110", configs));
}

TEST(Assembler, BGEZALToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("065100b7", convert_instruction_to_hex("BGEZAL $s2, 0b10110111", configs));
    EXPECT_EQ("06112222", convert_instruction_to_hex("BGEZAL $s0, 0x2222", configs));
    EXPECT_EQ("0631006f", convert_instruction_to_hex("BGEZAL $s1, 111", configs));
}

TEST(Assembler, BGTZToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("1e000007", convert_instruction_to_hex("BGTZ $s0, 0b111", configs));
    EXPECT_EQ("1e200111", convert_instruction_to_hex("BGTZ $s1, 0x111", configs));
    EXPECT_EQ("1e40000f", convert_instruction_to_hex("BGTZ $s2, 15", configs));
}

TEST(Assembler, BLEZToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("1aa0007b", convert_instruction_to_hex("BLEZ $s5, 123", configs));
    EXPECT_EQ("1ae00123", convert_instruction_to_hex("BLEZ $s7, 0x123", configs));
    EXPECT_EQ("1ac00007", convert_instruction_to_hex("BLEZ $s6, 0b111", configs));
}

TEST(Assembler, BLTZToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("06800015", convert_instruction_to_hex("BLTZ $s4, 0x15", configs));
    EXPECT_EQ("0660000f", convert_instruction_to_hex("BLTZ $s3, 15", configs));
    EXPECT_EQ("06e0000f", convert_instruction_to_hex("BLTZ $s7, 0b1111", configs));
}

TEST(Assembler, BLTZALToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("06700033", convert_instruction_to_hex("BLTZAL $s3, 0b110011", configs));
    EXPECT_EQ("06f0000b", convert_instruction_to_hex("BLTZAL $s7, 11", configs));
    EXPECT_EQ("0630011f", convert_instruction_to_hex("BLTZAL $s1, 0x11F", configs));
}

TEST(Assembler, BNEToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("16b600ff", convert_instruction_to_hex("BNE $s5, $s6, 0xFF", configs));
    EXPECT_EQ("1634000a", convert_instruction_to_hex("BNE $s1, $s4, 10", configs));
    EXPECT_EQ("16760002", convert_instruction_to_hex("BNE $s3, $s6, 0b10", configs));
}

TEST(Assembler, DIVToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02be001a", convert_instruction_to_hex("DIV $s5, $s8", configs));
    EXPECT_EQ("0253001a", convert_instruction_to_hex("DIV $s2, $s3", configs));
    EXPECT_EQ("02f5001a", convert_instruction_to_hex("DIV $s7, $s5", configs));
}

TEST(Assembler, DIVUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("0251001b", convert_instruction_to_hex("DIVU $s2, $s1", configs));
    EXPECT_EQ("0275001b", convert_instruction_to_hex("DIVU $s3, $s5", configs));
    EXPECT_EQ("0236001b", convert_instruction_to_hex("DIVU $s1, $s6", configs));
}

TEST(Assembler, JToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("08001234", convert_instruction_to_hex("J 0x1234", configs));
    EXPECT_EQ("0800000f", convert_instruction_to_hex("J 0b1111", configs));
    EXPECT_EQ("08000094", convert_instruction_to_hex("J 148", configs));
}

TEST(Assembler, JALToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("0c0000ff", convert_instruction_to_hex("JAL 0xFF", configs));
    EXPECT_EQ("0c00001d", convert_instruction_to_hex("JAL 0b11101", configs));
    EXPECT_EQ("0c00008c", convert_instruction_to_hex("JAL 140", configs));
}

TEST(Assembler, JALRToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02008809", convert_instruction_to_hex("JALR $s1, $s0", configs));
    EXPECT_EQ("02809009", convert_instruction_to_hex("JALR $s2, $s4", configs));
    EXPECT_EQ("0240b809", convert_instruction_to_hex("JALR $s7, $s2", configs));
    EXPECT_EQ("02a0f809", convert_instruction_to_hex("JALR $s5", configs));
    EXPECT_EQ("02e0f809", convert_instruction_to_hex("JALR $s7", configs));
}

TEST(Assembler, JRToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("03e00008", convert_instruction_to_hex("JR $ra", configs));
    EXPECT_EQ("02000008", convert_instruction_to_hex("JR $s0", configs));
    EXPECT_EQ("02200008", convert_instruction_to_hex("JR $s1", configs));
    EXPECT_EQ("00000008", convert_instruction_to_hex("JR $zero #l1", configs));
    EXPECT_EQ("00000008", convert_instruction_to_hex("JR $0 #l1", configs));
}

TEST(Assembler, LBToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("82d23456", convert_instruction_to_hex("LB $s2, 0x3456($s6)", configs));
    EXPECT_EQ("82b1006f", convert_instruction_to_hex("LB $s1, 111($s5)", configs));
    EXPECT_EQ("82700007", convert_instruction_to_hex("LB $s0, 0b111($s3)", configs));
}

TEST(Assembler, LBUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("92b41234", convert_instruction_to_hex("LBU $s4, 0x1234($s5)", configs));
    EXPECT_EQ("92560016", convert_instruction_to_hex("LBU $s6, 22($s2)", configs));
    EXPECT_EQ("92b2001d", convert_instruction_to_hex("LBU $s2, 0b11101($s5)", configs));
}

TEST(Assembler, LHToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("86911256", convert_instruction_to_hex("LH $s1, 0x1256($s4)", configs));
    EXPECT_EQ("86930079", convert_instruction_to_hex("LH $s3, 121($s4)", configs));
    EXPECT_EQ("86120007", convert_instruction_to_hex("LH $s2, 0b111($s0)", configs));
}

TEST(Assembler, LHUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("96727856", convert_instruction_to_hex("LHU $s2, 0x7856($s3)", configs));
    EXPECT_EQ("96b4007a", convert_instruction_to_hex("LHU $s4, 122($s5)", configs));
    EXPECT_EQ("9633001f", convert_instruction_to_hex("LHU $s3, 0b11111($s1)", configs));
}

TEST(Assembler, LUIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("3c120073", convert_instruction_to_hex("LUI $s2, 0b1110011", configs));
    EXPECT_EQ("3c1504d2", convert_instruction_to_hex("LUI $s5, 1234", configs));
    EXPECT_EQ("3c175234", convert_instruction_to_hex("LUI $s7, 0x5234", configs));
}

TEST(Assembler, LWToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("8e30000c", convert_instruction_to_hex("LW $s0, 12($s1)", configs));
    EXPECT_EQ("8e3200fc", convert_instruction_to_hex("LW $s2, 0xFC($s1)", configs));
    EXPECT_EQ("8e320064", convert_instruction_to_hex("LW $s2, 0b1100100($s1)", configs));
}

TEST(Assembler, LWLToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("8ab30070", convert_instruction_to_hex("LWL $s3, 112($s5)", configs));
    EXPECT_EQ("8a7400fd", convert_instruction_to_hex("LWL $s4, 0xFD($s3)", configs));
    EXPECT_EQ("8ad50064", convert_instruction_to_hex("LWL $s5, 0b1100100($s6)", configs));
}

TEST(Assembler, LWRToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("9ad10075", convert_instruction_to_hex("LWR $s1, 117($s6)", configs));
    EXPECT_EQ("9a5500fa", convert_instruction_to_hex("LWR $s5, 0xfa($s2)", configs));
    EXPECT_EQ("9a97001c", convert_instruction_to_hex("LWR $s7, 0b11100($s4)", configs));
}

TEST(Assembler, MFLOToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("0000a012", convert_instruction_to_hex("MFLO $s4", configs));
    EXPECT_EQ("0000b012", convert_instruction_to_hex("MFLO $s6", configs));
}

TEST(Assembler, MTHIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02200011", convert_instruction_to_hex("MTHI $s1", configs));
    EXPECT_EQ("02e00011", convert_instruction_to_hex("MTHI $s7", configs));
}

TEST(Assembler, MTLOToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02400013", convert_instruction_to_hex("MTLO $s2", configs));
    EXPECT_EQ("02800013", convert_instruction_to_hex("MTLO $s4", configs));
}

TEST(Assembler, MULTToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02560018", convert_instruction_to_hex("MULT $s2, $s6", configs));
    EXPECT_EQ("02970018", convert_instruction_to_hex("MULT $s4, $s7", configs));
}

TEST(Assembler, MULTUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02350019", convert_instruction_to_hex("MULTU     $s1,    $s5", configs));
    EXPECT_EQ("02970019", convert_instruction_to_hex("MULTU $s4,   $s7", configs));
    EXPECT_EQ("02b60019", convert_instruction_to_hex("MULTU $s5, $s6", configs));
}

TEST(Assembler, ORToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02538825", convert_instruction_to_hex("OR $s1, $s2, $s3", configs));
    EXPECT_EQ("02f59025", convert_instruction_to_hex("OR $s2, $s7,   $s5", configs));
    EXPECT_EQ("02531025", convert_instruction_to_hex("OR $v0, $s2, $s3", configs));
}

TEST(Assembler, ORIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("3672000f", convert_instruction_to_hex("ORI $s2, $s3, 0b1111", configs));
    EXPECT_EQ("36b400ff", convert_instruction_to_hex("ORI $s4, $s5,   0xFF", configs));
}

TEST(Assembler, SBToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("a233000a", convert_instruction_to_hex("SB $s3, 10($s1)", configs));
    EXPECT_EQ("a2b20010", convert_instruction_to_hex("SB    $s2, 0x10($s5)", configs));
    EXPECT_EQ("a2d40002", convert_instruction_to_hex("SB $s4,   0b10($s6)", configs));
}

TEST(Assembler, SHToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("a672000b", convert_instruction_to_hex("SH $s2,   11($s3)", configs));
    EXPECT_EQ("a6f40010", convert_instruction_to_hex("SH $s4, 0x10($s7)", configs));
    EXPECT_EQ("a6b6000a", convert_instruction_to_hex("SH $s6,  0b1010($s5)", configs));
}

TEST(Assembler, SLLToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("0012a900", convert_instruction_to_hex("SLL $s5,   $s2, 0x4", configs));
    EXPECT_EQ("00148980", convert_instruction_to_hex("SLL $s1,  $s4,    6", configs));
    EXPECT_EQ("0015b8c0", convert_instruction_to_hex("SLL $s7,  $s5,     0x3", configs));
    EXPECT_EQ("00109500", convert_instruction_to_hex("SLL $s2, $s0, 0x14", configs));
}

TEST(Assembler, SLLVToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02d5a004", convert_instruction_to_hex("SLLV  $s4, $s5,    $s6", configs));
    EXPECT_EQ("02f59004", convert_instruction_to_hex("SLLV $s2,     $s5, $s7", configs));
    EXPECT_EQ("02728804", convert_instruction_to_hex("SLLV $s1, $s2,    $s3", configs));
}

TEST(Assembler, SLTToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("03d1b82a", convert_instruction_to_hex("SLT   $s7, $s8,   $s1", configs));
    EXPECT_EQ("02d1a02a", convert_instruction_to_hex("SLT $s4,    $s6,    $s1", configs));
    EXPECT_EQ("02b1902a", convert_instruction_to_hex("SLT $s2, $s5, $s1", configs));
}

TEST(Assembler, SLTIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("2ab60011", convert_instruction_to_hex("SLTI  $s6,  $s5, 0x11", configs));
    EXPECT_EQ("2a91000f", convert_instruction_to_hex("SLTI $s1, $s4, 0b1111", configs));
    EXPECT_EQ("2a710070", convert_instruction_to_hex("SLTI $s1, $s3, 112", configs));
}

TEST(Assembler, SLTIUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("2e540a11", convert_instruction_to_hex("SLTIU $s4,  $s2,   0xA11", configs));
    EXPECT_EQ("2e92003f", convert_instruction_to_hex("SLTIU $s2, $s4, 0b111111", configs));
    EXPECT_EQ("2eb6006f", convert_instruction_to_hex("SLTIU $s6, $s5, 111", configs));
}

TEST(Assembler, SLTUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("0275882b", convert_instruction_to_hex("SLTU $s1,  $s3,    $s5", configs));
    EXPECT_EQ("02b6a02b", convert_instruction_to_hex("SLTU $s4, $s5, $s6", configs));
    EXPECT_EQ("02d7882b", convert_instruction_to_hex("SLTU $s1, $s6, $s7", configs));
}

TEST(Assembler, SRAToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("00128cc3", convert_instruction_to_hex("SRA $s1,  $s2, $s3", configs));
    EXPECT_EQ("00178d03", convert_instruction_to_hex("SRA $s1,  $s7,     $s4", configs));
    EXPECT_EQ("00129c43", convert_instruction_to_hex("SRA $s3,  $s2,     $s1", configs));
}

TEST(Assembler, SRAVToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02b49007", convert_instruction_to_hex("SRAV   $s2,   $s4, $s5", configs));
    EXPECT_EQ("0291b807", convert_instruction_to_hex("SRAV $s7,  $s1,   $s4", configs));
}

TEST(Assembler, SRLToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("00168d02", convert_instruction_to_hex("SRL $s1,      $s6, $s4", configs));
    EXPECT_EQ("001794c2", convert_instruction_to_hex("SRL $s2, $s7, $s3", configs));
}

TEST(Assembler, SRLVToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02548806", convert_instruction_to_hex("SRLV      $s1, $s4, $s2", configs));
    EXPECT_EQ("0235b006", convert_instruction_to_hex("SRLV $s6, $s5,    $s1", configs));
}

TEST(Assembler, SUBUToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02349823", convert_instruction_to_hex("SUBU      $s3, $s1, $s4", configs));
    EXPECT_EQ("0253a823", convert_instruction_to_hex("SUBU $s5,    $s2, $s3", configs));
    EXPECT_EQ("0237b023", convert_instruction_to_hex("SUBU $s6, $s1,    $s7", configs));
}

TEST(Assembler, SWToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("ae30000e", convert_instruction_to_hex("SW $s0, 14($s1)", configs));
    EXPECT_EQ("ae3200fd", convert_instruction_to_hex("SW $s2, 0xFD($s1)", configs));
    EXPECT_EQ("ae320064", convert_instruction_to_hex("SW $s2, 0b1100100($s1)", configs));
}

TEST(Assembler, XORToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("02b28826", convert_instruction_to_hex("XOR $s1, $s5, $s2", configs));
    EXPECT_EQ("02779026", convert_instruction_to_hex("XOR $s2, $s3,  $s7", configs));
}

TEST(Assembler, XORIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("3a341425", convert_instruction_to_hex("XORI  $s4, $s1, 0x1425", configs));
    EXPECT_EQ("3ab1003d", convert_instruction_to_hex("XORI $s1, $s5, 0b111101", configs));
    EXPECT_EQ("3a9504e6", convert_instruction_to_hex("XORI $s5, $s4, 1254", configs));
    EXPECT_EQ("3a02ff56", convert_instruction_to_hex("XORI $v0, $s0, 0xff56", configs));
}

TEST(Assembler, MFHIToHexAssembly) {
    std::map<std::string, InstructionParseConfig> configs = initializeConfigMap();
    EXPECT_EQ("00001010", convert_instruction_to_hex("MFHI $v0", configs));
}