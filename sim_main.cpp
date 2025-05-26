#include "sv_wrap.cpp"
#include "func_sim/hart.hpp"
#include <iostream>

template<typename T1, typename T2>
bool check_states(T1 &sim1, T2 &sim2) {
    if (sim1.pc != sim2.pc) {
        std::cout << "pc has different values!\n";
        return false;
    }
    for (int i = 0; i < 32; i++)
        if (sim1.registers[i] != sim2.registers[i]) {
            std::cout << "reg " << i << " has different values!\n";
            return false;
        }
    return true;
}

int main(int argc, char** argv) {
    SVSim svsim;
    Hart hart;

    do { // TODO: check infinite loop
        svsim.exec_instr();
        hart.exec_instr();
    } while (!svsim.done and !hart.done and check_states(svsim, hart));

    if (svsim.done != hart.done)
        std::cout << "done has different states!\n";
}
