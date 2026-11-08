`timescale 1ns / 1ps

module apb_slave_uart (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output wire        PREADY,
    input  wire        uart_rx,
    output wire        uart_tx,
    input  wire        uart_clk_en  // Khóa Clock Enable t? PMU
);
    // ---- Register map chu?n hóa ----
    localparam OFFSET_TXDATA  = 12'h000;
    localparam OFFSET_RXDATA  = 12'h004;
    localparam OFFSET_STATUS  = 12'h008;
    localparam OFFSET_CONTROL = 12'h00C;

    wire [7:0] fifo_rx_data_out;
    wire       fifo_rx_empty;
    wire       fifo_tx_full;

    reg        fifo_tx_ena_wr;
    reg  [7:0] fifo_tx_data_in;
    reg        fifo_rx_ena_rd;

    uart #(
        .D_BIT   (8),
        .SB_TICK (16),
        .DVSR    (54),   
        .DVSR_BIT(6),    
        .FIFO_W  (2)
    ) u_uart (
        .ckht            (PCLK),
        .rst             (~PRESETn),
        .uart_rx         (uart_rx),
        .uart_tx         (uart_tx),
        .fifo_rx_ena_rd  (fifo_rx_ena_rd),
        .fifo_rx_data_out(fifo_rx_data_out),
        .fifo_rx_empty   (fifo_rx_empty),
        .fifo_tx_ena_wr  (fifo_tx_ena_wr),
        .fifo_tx_data_in (fifo_tx_data_in),
        .fifo_tx_full    (fifo_tx_full)
    );

    assign PREADY = 1'b1;

    // ---- S?A ??I: C?u trúc Clear-On-Gate chu?n ?? tri?t tiêu l?i Hold ----
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            fifo_tx_ena_wr  <= 1'b0;
            fifo_tx_data_in <= 8'h0;
            fifo_rx_ena_rd  <= 1'b0;
        end else begin
            // M?c ??nh luôn h? xung kích ?? tránh gi? tr?ng thái c? (Tránh Latch)
            fifo_tx_ena_wr <= 1'b0;
            fifo_rx_ena_rd <= 1'b0;

            if (uart_clk_en) begin 
                // Khi PMU cho phép m?, CPU m?i có quy?n can thi?p d? li?u
                if (PSEL && PENABLE && PWRITE) begin
                    case (PADDR[11:0])
                        OFFSET_TXDATA: begin
                            if (!fifo_tx_full) begin
                                fifo_tx_data_in <= PWDATA[7:0];
                                fifo_tx_ena_wr  <= 1'b1;
                            end
                        end
                        default: ;
                    endcase
                end

                if (PSEL && PENABLE && !PWRITE) begin
                    if (PADDR[11:0] == OFFSET_RXDATA && !fifo_rx_empty)
                        fifo_rx_ena_rd <= 1'b1;
                end
            end else begin
                // Ép toàn b? m?ch ??m bus v? tr?ng thái t?nh hoàn toàn khi ng?t Clock En
                fifo_tx_data_in <= 8'h0; 
            end
        end
    end

    // M?ch ??c t? h?p an toàn
    always @(*) begin
        PRDATA = 32'h0;
        if (PSEL && !PWRITE && uart_clk_en) begin
            case (PADDR[11:0])
                OFFSET_RXDATA: PRDATA = {24'h0, fifo_rx_data_out};
                OFFSET_STATUS: PRDATA = {30'h0, fifo_rx_empty, fifo_tx_full};
                default:       PRDATA = 32'h0;
            endcase
        end
    end

endmodule