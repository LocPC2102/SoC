`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 09:49:30 AM
// Design Name: 
// Module Name: control_unit
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
module control_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input [6:0] funct7,
    
    //Datapath Control Signal
    output reg reg_write, //1 to twrite to Register File
    output reg alu_src, // 0 for Register, 1 for Immediate
    output reg [3:0] alu_ctrl, //Tells the ALU what math to do
    output reg  branch, // 1 if this is a branch instruction
    
    //Memmory control Signal
    output reg mem_write, //1. to Write to RAM
    output reg mem_read, // 1 to Read to Ram
    output reg mem_to_reg// 1 to save RAM to Register, 0 to save ALU to register
    );
    
    always @(*) begin
        // Default all signals to 0 to prevent accidental writes
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_ctrl   = 4'b0000;
        branch     = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            // Math: Register-Register (add, sub)
            `OP_OP: begin
                reg_write = 1'b1;
                alu_src   = 1'b0; 
                if (funct3 == `F3_ADD_SUB) begin
                    if (funct7[5] == 1'b1) alu_ctrl = 4'b1000; // SUB
                    else                   alu_ctrl = 4'b0000; // ADD
                end
                else if (funct3 == `F3_AND) alu_ctrl = 4'b0111;
                else if (funct3 == `F3_OR)  alu_ctrl = 4'b0110;
                else if (funct3 == `F3_SLT) alu_ctrl = 4'b0010;
            end

            // Math: Register-Immediate (addi)
            `OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1; 
                if (funct3 == `F3_ADD_SUB) alu_ctrl = 4'b0000; // ADDI
                else if (funct3 == `F3_AND) alu_ctrl = 4'b0111; // ANDI
                else if (funct3 == `F3_OR)  alu_ctrl = 4'b0110; // ORI
            end

            // Branches (beq)
            `OP_BRANCH: begin
                branch    = 1'b1;
                alu_src   = 1'b0; 
                alu_ctrl  = 4'b1000; // SUB to compare
            end
            
            // --- NEW: Load from Memory (lw) ---
            `OP_LOAD: begin
                reg_write  = 1'b1;     // We are saving data to a register
                alu_src    = 1'b1;     // Use immediate for address offset
                alu_ctrl   = 4'b0000;  // ADD (Base Register + Offset)
                mem_read   = 1'b1;     // Turn on RAM read
                mem_to_reg = 1'b1;     // Route RAM output to Register File!
            end
            
            // --- NEW: Store to Memory (sw) ---
            `OP_STORE: begin
                reg_write  = 1'b0;     // Do NOT write to a register!
                alu_src    = 1'b1;     // Use immediate for address offset
                alu_ctrl   = 4'b0000;  // ADD (Base Register + Offset)
                mem_write  = 1'b1;     // Turn on RAM write!
            end
            `OP_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = 4'b1111; // LUI
            end
        endcase
    end
endmodule