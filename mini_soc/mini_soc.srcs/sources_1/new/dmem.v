`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2026 02:15:49 PM
// Design Name: 
// Module Name: dmem
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

module ahb_ram (
    input  wire        hclk,
    input  wire        hresetn,
    
    // AHB Slave interface
    input  wire        hsel,
    input  wire [31:0] haddr,
    input  wire [31:0] hwdata,
    input  wire        hwrite,
    input  wire [1:0]  htrans,
    output wire [31:0] hrdata,
    output wire        hreadyout
);

    // 4KB memory - 1024 words x 32-bit
    reg [31:0] memory [0:1023];

    // Pipeline registers - latch address phase (Cycle 1)
    // Data phase arrives Cycle 2 theo AHB pipelined spec
    reg [31:0] saved_addr;
    reg        saved_write;
    reg        active;

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h0;
    end

    // ---- Cycle 1: Address phase - latch ----
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            saved_addr  <= 32'h0;
            saved_write <= 1'b0;
            active      <= 1'b0;
        end else begin
            if (hsel && htrans == 2'b10) begin
                saved_addr  <= haddr;
                saved_write <= hwrite;
                active      <= 1'b1;
            end else begin
                active <= 1'b0;
            end
        end
    end

    // ---- Cycle 2: Data phase - write ----
    always @(posedge hclk) begin
        if (active && saved_write)
            memory[saved_addr[11:2]] <= hwdata;
    end

    // ---- Combinational read ----
    assign hrdata    = (hsel && !hwrite) ? memory[haddr[11:2]] : 32'h0;
    assign hreadyout = 1'b1;  

endmodule