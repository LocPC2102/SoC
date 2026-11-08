`timescale 1ns / 1ps
module apb_interconnect (
    input  wire        PCLK,
    input  wire        PRESETn,

    // APB master side (t? ahb_to_apb)
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output reg         PREADY,

    // UART pins
    input  wire        uart_rx,
    output wire        uart_tx,

    // SPI pins
    output wire        spi_sclk,
    output wire        spi_cs_n,
    output wire        spi_mosi,
    input  wire        spi_miso,

    // I2C pins
    inout  wire        i2c_sda,
    output wire        i2c_scl,

    // Gated clocks t? PMU
    input  wire        gated_uart_clk,
    input  wire        gated_spi_clk,
    input  wire        gated_i2c_clk
);

    // ---- Address decode - PADDR[31:12] ----
    localparam UART_BASE = 20'h40000; // 0x4000_0000
    localparam SPI_BASE  = 20'h40001; // 0x4000_1000
    localparam I2C_BASE  = 20'h40002; // 0x4000_2000

    wire PSEL_uart = PSEL && (PADDR[31:12] == UART_BASE);
    wire PSEL_spi  = PSEL && (PADDR[31:12] == SPI_BASE);
    wire PSEL_i2c  = PSEL && (PADDR[31:12] == I2C_BASE);

    // ---- PRDATA và PREADY t?ng slave ----
    wire [31:0] PRDATA_uart;
    wire [31:0] PRDATA_spi;
    wire [31:0] PRDATA_i2c;
    wire        PREADY_uart;
    wire        PREADY_spi;
    wire        PREADY_i2c;

    // ---- UART slave ----
    apb_slave_uart u_uart (
        .PCLK    (gated_uart_clk),
        .PRESETn (PRESETn),
        .PADDR   (PADDR),
        .PSEL    (PSEL_uart),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA_uart),
        .PREADY  (PREADY_uart),
        .uart_rx (uart_rx),
        .uart_tx (uart_tx)
    );

    // ---- SPI slave ----
    apb_slave_spi u_spi (
        .PCLK     (gated_spi_clk),
        .PRESETn  (PRESETn),
        .PADDR    (PADDR),
        .PSEL     (PSEL_spi),
        .PENABLE  (PENABLE),
        .PWRITE   (PWRITE),
        .PWDATA   (PWDATA),
        .PRDATA   (PRDATA_spi),
        .PREADY   (PREADY_spi),
        .spi_sclk (spi_sclk),
        .spi_cs_n (spi_cs_n),
        .spi_mosi (spi_mosi),
        .spi_miso (spi_miso)
    );

    // ---- I2C slave ----
    apb_slave_i2c u_i2c (
        .PCLK    (gated_i2c_clk),
        .PRESETn (PRESETn),
        .PADDR   (PADDR),
        .PSEL    (PSEL_i2c),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA_i2c),
        .PREADY  (PREADY_i2c),
        .i2c_sda (i2c_sda),
        .i2c_scl (i2c_scl)
    );

    // ---- PRDATA MUX ----
    always @(*) begin
        if (PSEL_uart) begin
            PRDATA = PRDATA_uart;
            PREADY = PREADY_uart;
        end else if (PSEL_spi) begin
            PRDATA = PRDATA_spi;
            PREADY = PREADY_spi;
        end else if (PSEL_i2c) begin
            PRDATA = PRDATA_i2c;
            PREADY = PREADY_i2c;
        end else begin
            PRDATA = 32'h0;
            PREADY = 1'b1;
        end
    end

endmodule