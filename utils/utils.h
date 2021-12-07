#include <string>

#ifndef CPU_CW_UTILS_H
#define CPU_CW_UTILS_H

std::string trim(std::string str) {
    str.erase(0, str.find_first_not_of(' '));
    str.erase(str.find_last_not_of(' ') + 1);
    return str;
}

#endif
