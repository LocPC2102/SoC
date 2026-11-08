module spi (
    input  wire       clk,
    input  wire       rst_n,

    // Master user interface
    input  wire       start,
    input  wire [7:0] master_tx,
    output wire [7:0] master_rx,
    output wire       master_busy,
    output wire       master_done,

    // B?n có th? gi? ho?c comment các c?ng slave này l?i ?? tránh báo l?i l?ng l?
    input  wire [7:0] slave_tx,
    output wire [7:0] slave_rx,
    output wire       slave_done,

    // External SPI pins
    output wire       sclk,
    output wire       cs_n,
    output wire       mosi,
    input  wire       miso
);

    // CH? GI? L?I KH?I MASTER ?? N?P CHIP
    spi_master #(.CLK_DIV(4)) u_master (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),
        .tx_data (master_tx),
        .rx_data (master_rx),
        .busy    (master_busy),
        .done    (master_done),
        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso)
    );

    // KHOÁ ?O?N SLAVE NÀY L?I B?NG D?U COMMENT
    /*
    spi_slave u_slave (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_data (slave_tx),
        .rx_data (slave_rx),
        .done    (slave_done),
        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),
        .miso    (miso)
    );
    */

endmodule