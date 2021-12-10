#include <gtest/gtest.h>
#include <string>
#include <vector>
#include <sstream>
#include <regex>
#include "../utils.h"

std::string convertHexTo8CharHex(std::string hexNumber) {
    std::string result = trim(hexNumber);
    std::regex numberRegex("(0x)?(\\d+)");
    std::smatch matches;

    if (std::regex_search(hexNumber, matches, numberRegex)) {
        if (matches.size() == 3) {
            result = matches[2];
        } else {
            result = matches[1];
        }
        if (result.size() < 8) {
            result.insert(result.begin(), 8 - result.length(), '0');
        }
        return result;
    } else {
        return hexNumber;
    }
}

std::string convertExcelCSVLineTo8CharHexLine(std::string line) {
    std::string result = "";
    std::stringstream stream(line);
    std::string segment;
    std::vector<std::string> formattedNumbers;

    while (std::getline(stream, segment, ',')) {
        formattedNumbers.push_back(convertHexTo8CharHex(segment));
    }

    for (int i = 0; i < formattedNumbers.size() - 1; i++) {
        result += formattedNumbers[i] + ",";
    }

    result += formattedNumbers[formattedNumbers.size() - 1];

    return result;
}

TEST(Assembler, HexTo8CharHex) {
    EXPECT_EQ("00000000", convertHexTo8CharHex("0"));
    EXPECT_EQ("00000000", convertHexTo8CharHex("0 "));
    EXPECT_EQ("00000001", convertHexTo8CharHex("1"));
    EXPECT_EQ("00000001", convertHexTo8CharHex("    0x1 "));
    EXPECT_EQ("xxxxxxxx", convertHexTo8CharHex("xxxxxxxx"));
}

TEST(Assembler, HexLineTo8CharHexLine) {
    EXPECT_EQ(
            "00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000,00000000",
            convertExcelCSVLineTo8CharHexLine("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"));
}