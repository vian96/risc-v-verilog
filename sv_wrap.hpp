#include "Vriscv_pipeline.h"
#include "verilated.h"
#include <iostream>

class SVSim {
public:
    Vriscv_pipeline* top;

    size_t pc;
    unsigned int *registers;
    bool done;

    size_t instr_cnt;
    size_t cycle_cnt;

    void run_cycle() {
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
    }

    void dump_regs() {
        for (int i = 0; i < 32; i++)
            std::cout << std::dec << "reg[" << i << "] = 0x" << std::hex << registers[i] <<'\n';
    }

    SVSim() : top(new Vriscv_pipeline), done(0), pc(0) {
        top = new Vriscv_pipeline;

        registers = top->regs;

        top->clk = 0;
        top->reset = 1;
        top->pc_init = 4; // for cosim with prev sem
        top->dump = 0;

        // Hold reset for a few cycles
        for (int i = 0; i < 5; i++)
            run_cycle();

        top->reset = 0;
    }

    void exec_instr() {
        do {
            run_cycle();
            cycle_cnt++;
        } while (!top->ins_done);

        instr_cnt++;
        done = top->done;
        pc = top->pc_out;
    }
};

