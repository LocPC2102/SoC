`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2026 01:42:19 PM
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] a, //Operand A (from rs1)
    input [31:0] b, //Operand B(From rs2 or Immediate)
    input [3:0] alu_ctrl, // control signal telling the ALU what to dop
    
    output reg [31:0] result, //The 32 bit answer
    output wire zero // high if result is exactly 0
    
    );
    
    //Combinational logic for the ALU operations
    always @(*)begin
        case (alu_ctrl)
            4'b0000: result = a + b;
            4'b1000: result = a - b;
            4'b0001: result =  a << b[4:0]; //SLL(Shift left logiccal
            4'b0010: result  = ($signed(a) < $signed(b)) ? 1 : 0; //SLT(Set less than, signed)
            4'b0011: result = (a < b) ? 1 : 0; //Set less than but unsign
            4'b0100: result = a ^ b;
            4'b0101: result = a >> b[4:0];
            4'b1101: result = $signed(a) >>> b[4:0]; // SRA(Shift righ arithmetic)
            4'b0110: result =  a | b; //OR
            4'b0111: result = a  & b; //AND
            4'b1111:
                result = b;
            default: result =  32'h0;
        endcase
     end
     
     //The zero flag is true if all 32 bits of the result are 0
     assign zero = (result ==  32'h00000000);

endmodule