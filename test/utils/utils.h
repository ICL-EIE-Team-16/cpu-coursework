#include <string>
#include <locale>

#ifndef CPU_CW_UTILS_H
#define CPU_CW_UTILS_H

std::string trim(std::string str) {
    str.erase(0, str.find_first_not_of(' '));
    str.erase(str.find_last_not_of(' ') + 1);
    return str;
}

std::string to_upper(std::string str) {
    std::string result;
    std::locale loc;

    for (char i : str) {
        result += std::toupper(i, loc);
    }

    return result;
}

#endif
