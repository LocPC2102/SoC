`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2026 10:12:21 AM
// Design Name: 
// Module Name: imem
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

/*
In a computer, instructions are just like numbers (machine code) stored in memory, The FETCH stage acts as a bridge,
It take the current address from PC and "looj up" the corresponding instruction (IMEM)
- Read-Only: For most CPU core, IMEM is treated as read-only. We dont "write" to it during normal execution; we only "fetch" from it
- Single cycle: To keeps thing simple, we assume the IMEM responds instantly. As soon as the PC address changes, the instruction of that address apprear in the output wires
- Byte-Addressing vs Word-Addressing: RISC-V use byte-addressing, However, since each instructin is exactly 4 bytes (32bits), we often divide the PC by 4 (or ignore the last 2 bits) to find the correct index in the array
*/

module imem(
    input wire [31:0] pc,
    output wire [31:0] instruction //The 32-bit machine code at that address
    );
    //Define a memory array (e.g 64 words deep, reach 32-bits wide)
    reg[31:0] rom [0:63];
    //Initial block to load the test program (Summing number 1 to 9)
    //In real chip, this would loaded from a file and burn into ROM
    initial begin
        //"program.mem" is a plain text file containing hex instructions
        $readmemh("program.mem", rom);
    end
    
    // Combinational Read: Output the instruction at the PC address
    //Shift right by 2 (pc[31:2]) to convert byte-address to word-index
    assign instruction = rom[pc[31:2]];
    
endmodule