#include "sv_wrap.cpp"
#include "func_sim/hart.hpp"

#include <cstdint>
#include <fstream>
#include <iostream>

template<typename T1, typename T2>
bool check_states(T1 &sim1, T2 &sim2) {
    //if (sim1.pc != sim2.pc) {
    //    std::cerr << "pc has different values!\n";
    //    return false;
    //}
    for (int i = 0; i < 32; i++)
        if ((uint32_t)sim1.registers[i] != (uint32_t)sim2.registers[i]) {
            std::cerr << "reg " << i << " has different values!\n";
            std::cerr<< std::hex << sim1.registers[i] << ' ' << sim2.registers[i] << '\n';
            return false;
        }
    return true;
}

std::vector<char> readBinaryFileToVector_iterator(const std::string& filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return {};
    }
    return std::vector<char>((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
}

void fill_hart_mem(Hart &hart) {
    hart.memory = new uint8_t[1024];
    auto instrs = readBinaryFileToVector_iterator("./build/instr.bin");
    for (int i = 0; i < 1024 && i < instrs.size(); i++)
        hart.memory[i] = instrs[i];
        // FOR TEST 1
    ((uint32_t*)hart.memory)[75+0]  = 0xDEADBEEF;
    ((uint32_t*)hart.memory)[75+1]  = 0x12345678;
    ((uint32_t*)hart.memory)[75+2]  = 0xABCDEF01;
    ((uint32_t*)hart.memory)[75+3]  = 0xFEDCBA98;

    // FOR TEST 2
    ((uint32_t*)hart.memory)[75+20] = 0x00000005;
    ((uint32_t*)hart.memory)[75+21] = 0x0000000A;

    ((uint32_t*)hart.memory)[75+22] = 0x00000014;

    // TEST 3
    // will be overwritten by SW
    ((uint32_t*)hart.memory)[75+30] = 0xFFFFFFFF;

    // TEST 4
    ((uint32_t*)hart.memory)[75+32] = 0xAB0BAB0B;

    // TEST 5
    ((uint32_t*)hart.memory)[75+34] = 0x7c;  // 124+36=160=mem[40]
    ((uint32_t*)hart.memory)[75+40] = 0x5c;  // 92+92=184=mem[46]
    ((uint32_t*)hart.memory)[75+46] = 0xCEC0CEC0;
}

#define LOG(x) std::cout << #x << '\n';

int main(int argc, char** argv) {
    SVSim svsim;
    LOG(start)
    Hart hart;
    hart.pc = 4;

    LOG(init)

    fill_hart_mem(hart);

    LOG(filled)

    //for (int i = 0; i < 200; i++)
    //while (!svsim.done) {
    //    svsim.exec_instr();
    //}

    //for (int i = 0; i < 32; i++) {
    //    std::cout << std::dec << "reg[" << i << "] = 0x" << std::hex << svsim.registers[i] <<'\n';
    //}

    int cnt = 0;
    do { // TODO: check infinite loop
        LOG(loop)
        svsim.exec_instr();
        LOG(inner)
        hart.exec_instr();
        std::cout << "NOT FINISHED " << cnt++ << "\n";
    } while (!svsim.done and !hart.done and check_states(svsim, hart));

    std::cout << "FINISHED\n";

    if (svsim.done != hart.done)
        std::cerr << "done has different states!\n";
    else
      std::cout << "ALL GOOD!\n";
}
