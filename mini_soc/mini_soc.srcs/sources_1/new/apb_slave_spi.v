`timescale 1ns / 1ps

module apb_slave_spi (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output wire        PREADY,

    // External SPI pins
    output wire        spi_sclk,
    output wire        spi_cs_n,
    output wire        spi_mosi,
    input  wire        spi_miso
);

    // ---- Register map ----
    localparam OFFSET_TXDATA  = 12'h000; // W : master tx data
    localparam OFFSET_RXDATA  = 12'h004; // R : master rx data
    localparam OFFSET_STATUS  = 12'h008; // R : [0]BUSY [1]DONE
    localparam OFFSET_CONTROL = 12'h00C; // W : [0]START

    reg [7:0] master_tx_reg;
    reg        start_reg;

    wire [7:0] master_rx_wire;
    wire       master_busy_wire;
    wire       master_done_wire;

    // ---- SPI instance ----
    spi u_spi (
        .clk        (PCLK),
        .rst_n      (PRESETn),
        .start      (start_reg), // Xung start gi? tr?ng thái ?n ??nh cho ??n khi busy lên 1
        .master_tx  (master_tx_reg),
        .master_rx  (master_rx_wire),
        .master_busy(master_busy_wire),
        .master_done(master_done_wire),
        .slave_tx   (8'h00),
        .slave_rx   (),
        .slave_done (),
        // External pins
        .sclk       (spi_sclk),
        .cs_n       (spi_cs_n),
        .mosi       (spi_mosi),
        .miso       (spi_miso)
    );

    assign PREADY = 1'b1;

    // ---- APB Write & Auto-clear logic ----
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            master_tx_reg <= 8'h0;
            start_reg     <= 1'b0;
        end else begin
            // S?A ??I CHÍ M?NG: Ch? t? ??ng xóa l?nh start khi kh?i SPI Master báo ?ã nh?n và ?ang b?n ch?y (busy == 1)
            if (master_busy_wire) begin
                start_reg <= 1'b0;
            end

            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR[11:0])
                    OFFSET_TXDATA:  master_tx_reg <= PWDATA[7:0];
                    OFFSET_CONTROL: begin
                        if (PWDATA[0]) start_reg <= 1'b1; // Khóa gi? m?c 1
                    end
                    default: ;
                endcase
            end
        end
    end

    // ---- APB Read ----
    always @(*) begin
        PRDATA = 32'h0;
        if (PSEL && !PWRITE) begin
            case (PADDR[11:0])
                OFFSET_RXDATA: PRDATA = {24'h0, master_rx_wire};
                OFFSET_STATUS: PRDATA = {30'h0, master_done_wire, master_busy_wire};
                default:       PRDATA = 32'h0;
            endcase
        end
    end

endmodule