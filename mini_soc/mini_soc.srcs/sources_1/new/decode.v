`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2026 10:57:56 AM
// Design Name: 
// Module Name: decode
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
module decode(
    input [31:0] instruction,
    
    
    output wire[6:0] opcode, 
    output wire[4:0] rs1, // Source Register 1 Address
    output wire[4:0] rs2, //Source Register 2 Address
    output wire[4:0] rd,// Destination register address
    output wire[2:0] funct3,
    output wire[6:0] funct7
    );
    
    //Using the macros to slice the instruction!
    assign opcode = `OPCODE;
    assign rs1    = `RS1;
    assign rs2    = `RS2;
    assign rd     = `RD;
    assign funct3 = `FUNCT3;
    assign funct7 = `FUNCT7;
    
    
endmodule