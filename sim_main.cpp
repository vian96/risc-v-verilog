#include "Vtf_rvp.h"
#include "verilated.h"
//#include "verilated_vcd_c.h"
#include <iostream>

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Instantiate the top module
    Vtf_rvp* top = new Vtf_rvp;

    // Set up VCD tracing
    //VerilatedVcdC* tfp = new VerilatedVcdC;
    //top->trace(tfp, 99); // Trace 99 levels of hierarchy
    //tfp->open("sim.vcd");

    // Run simulation for a fixed number of cycles or until $finish
    vluint64_t max_time = 3000; // Adjust based on your needs
    while (!Verilated::gotFinish() && Verilated::time() < max_time) {
        top->eval();
        //tfp->dump(Verilated::time());
        Verilated::timeInc(1); // Increment simulation time
    }

    // Clean up
    //tfp->close();
    top->final();
    delete top;
    //delete tfp;

    std::cout << "Simulation finished at time: " << Verilated::time() << std::endl;
    return 0;
}
