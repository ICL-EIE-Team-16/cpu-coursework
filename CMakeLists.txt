cmake_minimum_required(VERSION 3.10)

project(CPU-CW)

set(CMAKE_CXX_STANDARD 20)

add_executable(CPU-CW test/utils/assembler.cpp test/utils/instruction-parse-config.h test/utils/opcodes.h test/utils/registers.h)
include(FetchContent)
FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_executable(assembler_test test/utils/test/assembler.cc)
target_link_libraries(
        assembler_test
        gtest_main
)

add_executable(reg-csv-ref-to-hex_test test/utils/test/reg-csv-ref-to-hex.cc)
target_link_libraries(
        reg-csv-ref-to-hex_test
        gtest_main
)

include(GoogleTest)
gtest_discover_tests(assembler_test)