`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 02:40:23 PM
// Design Name: 
// Module Name: pc_logic
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

/**
The program counter is a register that holds address of the next instruction your cpu will fetch from memory
At every clock cycle:
- Use PC -> fetch instruction from the memory
- Execute the instruction
- Update PC -> point to the next instruction
*/

module pc_logic(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_target,
    input  wire        take_br,
    input  wire        stall,     
    output reg  [31:0] pc
);
    wire [31:0] pc_next;
    assign pc_next = take_br ? pc_target : (pc + 32'd4);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h0;
        else if (!stall)            
            pc <= pc_next;
    end
endmodule