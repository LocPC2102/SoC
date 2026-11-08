`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 09:08:42 AM
// Design Name: 
// Module Name: cpu_core_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "riscv_defs.vh"

module cpu_core_tb();
  // --- 1. Global Signals ---
    reg clk;
    reg reset;

    // --- 2. Instantiate the CPU Core ---
    cpu_core uut (
        .clk(clk),
        .reset(reset)
    );

    // --- 3. Clock Generation (100MHz / 10ns period) ---
    always #5 clk = ~clk;

    // --- 4. Simulation Stimulus ---
    initial begin
       clk = 0;
        reset = 1;
        #15 reset = 0;

        // Run long enough for 9 loops to finish
        #600; 

        $display("--------------------------------------------------");
        $display("Simulation Finished.");
        $display("Final value of Register a0 (x10): %d", uut.my_regfile.registers[10]);
        $display("Final value of Register a1 (x11): %d", uut.my_regfile.registers[11]);
        $display("--------------------------------------------------");
        $finish;
    end

    // --- 5. Real-Time Execution Monitor ---
    // This will print to the TCL Console every time the PC changes.
    // Notice how we use "uut.my_regfile..." to peek inside the CPU's internal modules!
    initial begin
        $display(" Time |    PC    | Instruction | ALU Result | r10 (a0) | r11 (a1)");
        $display("------------------------------------------------------------------");
        $monitor("%5t | %h |   %h  | %10d | %8d | %8d", 
                 $time, 
                 uut.current_pc, 
                 uut.fetched_instruction, 
                 uut.alu_result, 
                 uut.my_regfile.registers[10], // Peeking at a0
                 uut.my_regfile.registers[11]  // Peeking at a1
        );
    end
endmodule