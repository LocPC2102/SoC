`timescale 1ns / 1ps

module i2c_top #(
    parameter SYS_FREQ = 100_000_000  // default 100MHz
)(
    input  clk,
    input  rst,
    input  newd,
    input  op,
    input  [6:0] addr,
    input  [7:0] din,
    output [7:0] dout,
    output busy,
    output ack_err,
    output done,
    inout  wire sda,
    output wire scl
);
    wire scl_master;
    assign scl = scl_master;

    
    i2c_master #(
        .sys_freq(SYS_FREQ)
    ) master_inst (
        .clk    (clk),
        .rst    (rst),
        .newd   (newd),
        .addr   (addr),
        .op     (op),
        .sda    (sda),          
        .scl    (scl_master),
        .din    (din),
        .dout   (dout),
        .busy   (busy),
        .ack_err(ack_err),
        .done   (done)
    );

    // VÔ HI?U HOÁ KH?I SLAVE GI? L?P NÀY ?? TRÁNH L?I SYNTHESIS
    /*
    i2c_Slave1 slave1_inst (
        .scl_s1 (scl_master),
        .clk    (clk),
        .rst    (rst),
        .sda_s1 (sda),          
        .ack_err(),
        .done   ()
    );
    */
    
endmodule