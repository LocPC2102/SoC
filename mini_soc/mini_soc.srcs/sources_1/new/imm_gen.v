`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 09:16:59 AM
// Design Name: 
// Module Name: imm_gen
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

module imm_gen(

    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    // Extract the opcode directly to know how to decode the immediate
    wire [6:0] opcode = `OPCODE;

    always @(*) begin
        case (opcode)
            // I-Type: addi, lw, etc. (Top 12 bits of the instruction)
            `OP_IMM, `OP_LOAD, `OP_JALR:
                // {20{...}} is Verilog's replication operator. It copies the sign bit 20 times.
                imm_out = { {20{instruction[31]}}, instruction[31:20] };

            // S-Type: sw, sh, sb (Immediate is split into two chunks)
            `OP_STORE:
                imm_out = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };

            // B-Type: beq, bne (Branch offsets, scrambled and implicitly multiplied by 2)
            `OP_BRANCH:
                imm_out = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };

            // U-Type: lui, auipc (Upper immediate, shifted left by 12)
            `OP_LUI:
                imm_out = { instruction[31:12], 12'b0 };

            // J-Type: jal (Jump offsets)
            `OP_JAL:
                imm_out = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

            // Default fallback
            default: 
                imm_out = {instruction[31:12],12'b0};
        endcase
    end
endmodule