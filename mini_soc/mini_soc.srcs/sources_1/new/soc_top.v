`timescale 1ns / 1ps

module soc_top (
    input  wire clk,
    input  wire reset,

    // UART pins
    input  wire uart_rx,
    output wire uart_tx,

    // SPI pins
    output wire spi_sclk,
    output wire spi_cs_n,
    output wire spi_mosi,
    input  wire spi_miso,

    // I2C pins
    inout  wire i2c_sda,
    output wire i2c_scl,

    // Debug pins
    output wire [31:0] out_pc,
    output wire [31:0] out_alu_result
);

    wire hresetn = ~reset;

    // AHB bus wires
    wire [31:0] haddr;
    wire [31:0] hwdata;
    wire        hwrite;
    wire [1:0]  htrans;
    wire [2:0]  hsize;
    wire [31:0] hrdata;
    wire        hready;

    // AHB slave wires
    wire        hsel_ram;
    wire        hreadyout_ram;
    wire [31:0] hrdata_ram;

    wire        hsel_pmu;
    wire        hreadyout_pmu;
    wire [31:0] hrdata_pmu;

    wire        hsel_apb;
    wire        hreadyout_apb;
    wire [31:0] hrdata_apb;

    // APB bus wires
    wire [31:0] paddr;
    wire        psel;
    wire        penable;
    wire        pwrite;
    wire [31:0] pwdata;
    wire [31:0] prdata;
    wire        pready; // Dây k?t n?i ph?n h?i tr?ng thái t? APB Bus lên AHB Bridge

    // PMU wires
    wire uart_clk_en;
    wire spi_clk_en;
    wire i2c_clk_en;

    wire gated_uart_clk = clk;
    wire gated_spi_clk  = clk;
    wire gated_i2c_clk  = clk;

    wire [31:0] imem_pc;
    wire [31:0] imem_instruction;

    // =========================================================================
    // AHB Interconnect - GI?I MÃ ??A CH? CHU?N (Không g?p htrans vào hsel)
    // =========================================================================
    assign hsel_ram = (haddr[31:16] == 16'h0000);  // 0x0000_0000
    assign hsel_apb = (haddr[31:16] == 16'h4000);  // 0x4000_0000
    assign hsel_pmu = (haddr[31:16] == 16'h6000);  // 0x6000_0000

    // HREADY MUX - Slave nào ?ang ho?t ??ng thì l?y HREADYOUT c?a Slave ?ó báo v? Core
    assign hready = (haddr[31:16] == 16'h0000) ? hreadyout_ram :
                    (haddr[31:16] == 16'h4000) ? hreadyout_apb :
                    (haddr[31:16] == 16'h6000) ? hreadyout_pmu : 1'b1;

    // HRDATA MUX
    assign hrdata = (haddr[31:16] == 16'h0000) ? hrdata_ram :
                    (haddr[31:16] == 16'h4000) ? hrdata_apb :
                    (haddr[31:16] == 16'h6000) ? hrdata_pmu : 32'h0;

    // =========================================================================
    // Module Instantiations
    // =========================================================================

    imem u_imem (
        .pc(imem_pc), .instruction(imem_instruction)
    );

    cpu_core u_cpu (
        .hclk(clk), .hresetn(hresetn), .out_pc(out_pc), .out_alu_result(out_alu_result),
        .haddr(haddr), .hwdata(hwdata), .hwrite(hwrite), .htrans(htrans), .hsize(hsize),
        .hrdata(hrdata), .hready(hready), .imem_pc(imem_pc), .imem_instruction(imem_instruction)
    );

    ahb_ram u_ram (
        .hclk(clk), .hresetn(hresetn), .hsel(hsel_ram),
        .haddr(haddr), .hwdata(hwdata), .hwrite(hwrite), .htrans(htrans),
        .hrdata(hrdata_ram), .hreadyout(hreadyout_ram)
    );

    ahb_pmu u_pmu (
        .hclk(clk), .hresetn(hresetn), .hsel(hsel_pmu),
        .haddr(haddr), .hwdata(hwdata), .hwrite(hwrite), .htrans(htrans),
        .hrdata(hrdata_pmu), .hreadyout(hreadyout_pmu),
        .uart_clk_en(uart_clk_en), .spi_clk_en(spi_clk_en), .i2c_clk_en(i2c_clk_en)
    );

    ahb_to_apb u_bridge (
        .hclk(clk), .hresetn(hresetn), .hsel(hsel_apb),
        .haddr(haddr), .hwdata(hwdata), .hwrite(hwrite), .htrans(htrans),
        .hrdata(hrdata_apb), .hreadyout(hreadyout_apb),
        .psel(psel), .penable(penable), .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata), 
        .prdata(prdata),
        .pready(pready) // ?Ã K?T N?I: Tránh m?t ??ng b? ho?c r?t chu k? d? li?u
    );

    apb_interconnect u_apb (
        .PCLK(clk), .PRESETn(hresetn),
        .PADDR(paddr), .PSEL(psel), .PENABLE(penable), .PWRITE(pwrite), .PWDATA(pwdata),
        .PRDATA(prdata),
        .PREADY(pready), // ?Ã K?T N?I: Tr? ng??c tín hi?u s?n sàng t? các Slave v? Bridge
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .spi_sclk(spi_sclk), .spi_cs_n(spi_cs_n), .spi_mosi(spi_mosi), .spi_miso(spi_miso),
        .i2c_sda(i2c_sda), .i2c_scl(i2c_scl),
        .gated_uart_clk(gated_uart_clk), .gated_spi_clk(gated_spi_clk), .gated_i2c_clk(gated_i2c_clk)
    );

endmodule