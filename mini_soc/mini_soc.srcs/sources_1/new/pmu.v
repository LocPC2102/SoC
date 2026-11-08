`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2026 07:42:36 AM
// Design Name: 
// Module Name: pmu
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

module ahb_pmu (
    input  wire        hclk,
    input  wire        hresetn,

    // AHB Slave interface
    input  wire        hsel,
    input  wire [31:0] haddr,
    input  wire [31:0] hwdata,
    input  wire        hwrite,
    input  wire [1:0]  htrans,
    output wire [31:0] hrdata,
    output wire        hreadyout,

    // Clock enable outputs
    output wire        uart_clk_en,
    output wire        spi_clk_en,
    output wire        i2c_clk_en
);

    // ---- Single register at offset 0x00 ----
    // bit[0] = uart_clk_en
    // bit[1] = spi_clk_en
    // bit[2] = i2c_clk_en
    reg [31:0] clk_enable_reg;

    // ---- Pipeline register - latch address phase ----
    reg [31:0] saved_addr;
    reg        saved_write;
    reg        active;

    // ---- Cycle 1: Address phase ----
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
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            clk_enable_reg <= 32'h0; // t?t c? peripheral t?t khi reset
        end else begin
            if (active && saved_write) begin
                if (saved_addr[7:0] == 8'h00)
                    clk_enable_reg <= hwdata;
            end
        end
    end

    // ---- Combinational read ----
    assign hrdata    = (hsel && !hwrite && haddr[7:0] == 8'h00) ? clk_enable_reg : 32'h0;
    assign hreadyout = 1'b1;

    // ---- Clock enable outputs ----
    assign uart_clk_en = clk_enable_reg[0];
    assign spi_clk_en  = clk_enable_reg[1];
    assign i2c_clk_en  = clk_enable_reg[2];

endmodule
