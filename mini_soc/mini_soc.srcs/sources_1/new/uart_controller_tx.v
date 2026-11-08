`timescale 1ns / 1ps
module uart_controller_tx #(
    parameter D_BIT   = 8,
    parameter SB_TICK = 16
)(
    input  wire             ckht,
    input  wire             rst,
    input  wire             s_tick,
    input  wire [D_BIT-1:0] tx_data,
    input  wire             tx_fifo_empty,
    output reg              tx_done_tick,
    output wire             tx
);
    localparam [1:0] idle  = 2'b00,
                     start = 2'b01,
                     data  = 2'b10,
                     stop  = 2'b11;

    reg [1:0]       state_r, state_n;
    reg [3:0]       s_r, s_n;
    reg [2:0]       n_r, n_n;
    reg [D_BIT-1:0] b_r, b_n;
    reg             tx_r, tx_n;

    // posedge ?? ??ng b? v?i APB
    always @(posedge ckht or posedge rst) begin
        if (rst) begin
            state_r <= idle;
            s_r     <= 4'b0;
            n_r     <= 3'b0;
            b_r     <= {D_BIT{1'b0}};
            tx_r    <= 1'b1;
        end else begin
            state_r <= state_n;
            s_r     <= s_n;
            n_r     <= n_n;
            b_r     <= b_n;
            tx_r    <= tx_n;
        end
    end

    always @(*) begin
        state_n      = state_r;
        s_n          = s_r;
        n_n          = n_r;
        b_n          = b_r;
        tx_n         = tx_r;
        tx_done_tick = 1'b0;

        case (state_r)
            idle: begin
                tx_n = 1'b1;
                if (!tx_fifo_empty) begin
                    state_n = start;
                    s_n     = 4'b0;
                    b_n     = tx_data;
                end
            end

            start: begin
                tx_n = 1'b0;
                if (s_tick) begin
                    if (s_r == 4'd15) begin
                        state_n = data;
                        s_n     = 4'b0;
                        n_n     = 3'b0;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            data: begin
                tx_n = b_r[0];
                if (s_tick) begin
                    if (s_r == 4'd15) begin
                        s_n = 4'b0;
                        b_n = {1'b0, b_r[D_BIT-1:1]};
                        if (n_r == (D_BIT - 1))
                            state_n = stop;
                        else
                            n_n = n_r + 1'b1;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            stop: begin
                tx_n = 1'b1;
                if (s_tick) begin
                    if (s_r == (SB_TICK - 1)) begin
                        state_n      = idle;
                        tx_done_tick = 1'b1;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            default: state_n = idle;
        endcase
    end

    assign tx = tx_r;
endmodule