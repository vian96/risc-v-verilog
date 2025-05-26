#include "Vriscv_pipeline.h"
#include "verilated.h"
#include <cstdint>
#include <iostream>

class SVSim {
private:
    Vriscv_pipeline* top;

public:
    unsigned int &pc;
    std::array<int32_t, 32> registers;
    bool done;

    SVSim() : top(new Vriscv_pipeline), pc(top->pc_out) {
        top = new Vriscv_pipeline;

        top->clk = 0;
        top->reset = 1;
        top->pc_init = 0;
        top->dump = 0;

        // Hold reset for a few cycles
        for (int i = 0; i < 10; i++) {
            top->clk = !top->clk;
            top->eval();
            Verilated::timeInc(1);
        }

        top->reset = 0;
    }

    void exec_instr() {
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
    }
};

