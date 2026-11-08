`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2026 04:00:26 PM
// Design Name: 
// Module Name: spi_tb_slave_to_master
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


module spi_tb_slave_to_master;
 
    reg        clk, rst_n;
    reg        start;
    reg  [7:0] master_tx;
    wire [7:0] master_rx;
    wire       master_busy;
    wire       master_done;
    reg  [7:0] slave_tx;
    wire [7:0] slave_rx;
    wire       slave_done;
 
    // 10ns period = 100MHz
    always #5 clk = ~clk;
 
    spi u_spi (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .master_tx  (master_tx),
        .master_rx  (master_rx),
        .master_busy(master_busy),
        .master_done(master_done),
        .slave_tx   (slave_tx),
        .slave_rx   (slave_rx),
        .slave_done (slave_done)
    );
 
    initial begin
        $dumpfile("spi_slave_to_master.vcd");
        $dumpvars(0, spi_tb_slave_to_master);
    end
 
    initial begin
        clk       = 0;
        rst_n     = 0;
        start     = 0;
        master_tx = 8'h00;
        slave_tx  = 8'h5A; // 01011010
 
        // Reset 2 cycles
        #20 rst_n = 1;
        #30;
 
        // --- Transaction 1: Slave TX = 0x5A ---
        $display("[Figure 5] Transaction 1: Slave TX = 0x5A");
        @(posedge clk); #1;
        start = 1;
        @(posedge clk); #1;
        start = 0;
 
        @(posedge master_done); #1;
        $display("  master_rx = 0x%02X | %s", master_rx, (master_rx===8'h5A)?"PASS":"FAIL");
 
        // Idle gap: 20 cycles
        repeat(20) @(posedge clk);
 
        // --- Transaction 2: Slave TX = 0x33 ---
        slave_tx = 8'h33; // 00110011
        $display("[Figure 5] Transaction 2: Slave TX = 0x33");
        @(posedge clk); #1;
        start = 1;
        @(posedge clk); #1;
        start = 0;
 
        @(posedge master_done); #1;
        $display("  master_rx = 0x%02X | %s", master_rx, (master_rx===8'h33)?"PASS":"FAIL");
 
        // Padding cuoi
        repeat(30) @(posedge clk);
        $display("Simulation done.");
        $finish;
    end
 
endmodule