`timescale 1ns / 1ps

module spi_master #(
    parameter CLK_DIV = 4       
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,        
    input  wire [7:0] tx_data,      
    output reg  [7:0] rx_data,      
    output reg         busy,         
    output reg         done,         
    output reg         sclk,
    output reg         cs_n,         
    output reg         mosi,
    input  wire        miso,
    input  wire        spi_clk_en    // Khóa Clock Enable t? PMU
);
 
    reg [7:0] shift_tx;             
    reg [7:0] shift_rx;             
    reg [2:0] bit_cnt;              
    reg [7:0] clk_cnt;              
 
    localparam IDLE     = 2'd0;
    localparam TRANSFER = 2'd1;
    localparam FINISH   = 2'd2;
 
    reg [1:0] state;
 
    // ---- S?A ??I: ??ng b? hóa hoàn toàn nhánh rst và gater ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            sclk     <= 0;
            cs_n     <= 1;
            mosi     <= 0;
            busy     <= 0;
            done     <= 0;
            clk_cnt  <= 0;
            bit_cnt  <= 7;
            shift_tx <= 0;
            shift_rx <= 0;
            rx_data  <= 0;
        end else begin
            if (spi_clk_en) begin 
                done <= 1'b0; // Default clear
 
                case (state)
                    IDLE: begin
                        sclk    <= 0;
                        cs_n    <= 1;
                        clk_cnt <= 0;
                        bit_cnt <= 7;
 
                        if (start) begin
                            shift_tx <= tx_data;
                            busy     <= 1;
                            cs_n     <= 0;          
                            mosi     <= tx_data[7]; 
                            state    <= TRANSFER;
                        end
                    end
 
                    TRANSFER: begin
                        clk_cnt <= clk_cnt + 1;
                        if (clk_cnt == CLK_DIV - 1) begin
                            clk_cnt <= 0;
                            sclk    <= ~sclk; 
 
                            if (sclk == 0) begin
                                shift_rx <= {shift_rx[6:0], miso};
                            end
 
                            if (sclk == 1) begin
                                if (bit_cnt == 0) begin
                                    state <= FINISH;
                                end else begin
                                    bit_cnt  <= bit_cnt - 1;
                                    shift_tx <= {shift_tx[6:0], 1'b0};
                                    mosi     <= shift_tx[6]; 
                                end
                            end
                        end
                    end
 
                    FINISH: begin
                        sclk    <= 0;
                        cs_n    <= 1;
                        busy    <= 0;
                        done    <= 1;
                        rx_data <= shift_rx;
                        bit_cnt <= 7;
                        state   <= IDLE;
                    end
                    default: state <= IDLE;
                endcase
            end else begin
                
                done <= 1'b0;
                busy <= 1'b0;
            end
        end
    end
 
endmodule