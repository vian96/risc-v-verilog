#include "Vriscv_pipeline.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vriscv_pipeline* top = new Vriscv_pipeline;

    top->clk = 0;
    top->reset = 1;
    top->pc_init = 0;
    top->dump = 0;

    // Hold reset for 5 cycles (10 edges)
    for (int i = 0; i < 10; i++) {
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
    }

    top->reset = 0;

    // Run until pc_out >= 150 or time >= 2000
    while (top->pc_out < 150 && Verilated::time() < 2000) {
        top->clk = !top->clk;
        top->eval();
        std::cout << "Time: " << Verilated::time() << ", pc_out: " << top->pc_out << std::endl;
        Verilated::timeInc(1);
    }

    // Wait 4 cycles
    for (int i = 0; i < 8; i++) {
        top->clk = !top->clk;
        top->eval();
        Verilated::timeInc(1);
    }

    // Trigger register dump
    top->dump = 1;
    top->clk = !top->clk;
    top->eval();
    Verilated::timeInc(1);
    top->clk = !top->clk;
    top->eval();
    Verilated::timeInc(1);

    top->final();
    delete top;

    std::cout << "Simulation finished at time: " << Verilated::time() << std::endl;
    return 0;
}
