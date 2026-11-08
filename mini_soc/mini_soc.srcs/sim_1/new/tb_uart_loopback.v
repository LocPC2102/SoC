`timescale 1ns / 1ps
module tb_uart_loopback;

    localparam D_BIT    = 8;
    localparam SB_TICK  = 16;
    localparam DVSR     = 163;
    localparam DVSR_BIT = 9;
    localparam FIFO_W   = 2;

    localparam FRAME_TIME = 260800;

    reg ckht;
    reg rst;

    initial ckht = 0;
    always #5 ckht = ~ckht;

    reg              fifo_tx_ena_wr;
    reg  [D_BIT-1:0] fifo_tx_data_in;
    reg              fifo_rx_ena_rd;
    wire             fifo_tx_full;
    wire             fifo_rx_empty;
    wire [D_BIT-1:0] fifo_rx_data_out;

    wire uart_tx_pin;
    wire uart_rx_pin;
    assign uart_rx_pin = uart_tx_pin;

    // ============================================================
    // 6 signals c?n xem - ?úng hình 4.3
    // ============================================================
    reg  [D_BIT-1:0] tx_data;
    wire             tx_active;
    wire             tx_pin;
    wire [D_BIT-1:0] rx_data;   // wire, không ph?i reg
    wire             rx_done;

    assign tx_active = (dut.U3.state_r != 2'b00);
    assign tx_pin    = uart_tx_pin;
    assign rx_data   = dut.U1.b_r;   // shift register ? th?y 00?08?...?48
    assign rx_done   = dut.U1.rx_done_tick;

    // ============================================================
    // DUT
    // ============================================================
    uart #(
        .D_BIT   (D_BIT),
        .SB_TICK (SB_TICK),
        .DVSR    (DVSR),
        .DVSR_BIT(DVSR_BIT),
        .FIFO_W  (FIFO_W)
    ) dut (
        .ckht            (ckht),
        .rst             (rst),
        .uart_rx         (uart_rx_pin),
        .uart_tx         (uart_tx_pin),
        .fifo_rx_ena_rd  (fifo_rx_ena_rd),
        .fifo_rx_data_out(fifo_rx_data_out),
        .fifo_rx_empty   (fifo_rx_empty),
        .fifo_tx_ena_wr  (fifo_tx_ena_wr),
        .fifo_tx_data_in (fifo_tx_data_in),
        .fifo_tx_full    (fifo_tx_full)
    );

    // ============================================================
    // Test Sequence
    // ============================================================
    initial begin
        rst             = 1;
        fifo_tx_ena_wr  = 0;
        fifo_tx_data_in = 8'h00;
        fifo_rx_ena_rd  = 0;
        tx_data         = 8'h00;

        repeat(4) @(negedge ckht);
        rst = 0;
        repeat(2) @(negedge ckht);

        // Ghi 0x48 vào TX FIFO
        @(negedge ckht);
        fifo_tx_data_in = 8'h48;
        tx_data         = 8'h48;

        @(negedge ckht);
        fifo_tx_ena_wr  = 1'b1;

        @(negedge ckht);
        fifo_tx_ena_wr  = 1'b0;

        // ??i rx_done pulse
        @(posedge rx_done);

        // Pop FIFO ngay sau rx_done
        repeat(2) @(negedge ckht);
        fifo_rx_ena_rd = 1'b1;
        @(negedge ckht);
        fifo_rx_ena_rd = 1'b0;

        // ??i thêm ?? quan sát waveform
        #(FRAME_TIME);

        $display("=====================================================");
        $display("  Sent     = 0x%02h", tx_data);
        $display("  Received = 0x%02h", fifo_rx_data_out);
        if (fifo_rx_data_out === 8'h48)
            $display("  [PASS] Loopback SUCCESS!");
        else
            $display("  [FAIL] Expected 0x48, got 0x%02h", fifo_rx_data_out);
        $display("=====================================================");

        $finish;
    end

    always @(posedge rx_done)
        $display("[%0t ns] rx_done", $time);

endmodule
