`timescale 1ns / 1ps
module uart_controller_rx #(
    parameter D_BIT   = 8,
    parameter SB_TICK = 16
)(
    input  wire             ckht,
    input  wire             rst,
    input  wire             rx,
    input  wire             s_tick,
    output reg              rx_done_tick,
    output wire [D_BIT-1:0] rx_data
);
    localparam [1:0] idle  = 2'b00,
                     start = 2'b01,
                     data  = 2'b10,
                     stop  = 2'b11;

    reg [1:0]       state_r, state_n;
    reg [3:0]       s_r, s_n;
    reg [2:0]       n_r, n_n;
    reg [D_BIT-1:0] b_r, b_n;

    // posedge ?? ??ng b? v?i APB
    always @(posedge ckht or posedge rst) begin
        if (rst) begin
            state_r <= idle;
            s_r     <= 4'b0;
            n_r     <= 3'b0;
            b_r     <= {D_BIT{1'b0}};
        end else begin
            state_r <= state_n;
            s_r     <= s_n;
            n_r     <= n_n;
            b_r     <= b_n;
        end
    end

    always @(*) begin
        state_n      = state_r;
        s_n          = s_r;
        n_n          = n_r;
        b_n          = b_r;
        rx_done_tick = 1'b0;

        case (state_r)
            idle: begin
                if (rx == 1'b0) begin
                    state_n = start;
                    s_n     = 4'b0;
                end
            end

            start: begin
                if (s_tick) begin
                    if (s_r == 4'd7) begin
                        state_n = data;
                        s_n     = 4'b0;
                        n_n     = 3'b0;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            data: begin
                if (s_tick) begin
                    if (s_r == 4'd15) begin
                        s_n = 4'b0;
                        b_n = {rx, b_r[D_BIT-1:1]};
                        if (n_r == (D_BIT - 1))
                            state_n = stop;
                        else
                            n_n = n_r + 1'b1;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            stop: begin
                if (s_tick) begin
                    if (s_r == (SB_TICK - 1)) begin
                        state_n      = idle;
                        rx_done_tick = 1'b1;
                    end else
                        s_n = s_r + 1'b1;
                end
            end

            default: state_n = idle;
        endcase
    end

    assign rx_data = b_r;
endmodule