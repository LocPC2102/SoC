module uart #(
    parameter D_BIT    = 8,   
    parameter SB_TICK  = 16,  
    parameter DVSR     = 163, 
    parameter DVSR_BIT = 9,   
    parameter FIFO_W   = 2   
)(
    input  wire              ckht,              
    input  wire              rst,               
    input  wire              uart_rx,           
    output wire              uart_tx,           
    
   
    input  wire              fifo_rx_ena_rd,    
    output wire [D_BIT-1:0]  fifo_rx_data_out,  
    output wire              fifo_rx_empty,     
    
  
    input  wire              fifo_tx_ena_wr,    
    input  wire [D_BIT-1:0]  fifo_tx_data_in,   
    output wire              fifo_tx_full       
);

    wire             s_tick;
    wire [D_BIT-1:0] fifo_rx_data_in;
    wire             fifo_rx_wr;
    wire [D_BIT-1:0] fifo_tx_data_out;
    wire             fifo_tx_rd;
    wire             fifo_tx_empty;
    wire             fifo_rx_full_wire; 

    baud_rate_generator #(
        .N(DVSR_BIT),
        .M(DVSR)
    ) U0 (
        .ckht(ckht),
        .rst(rst),
        .tick(s_tick)
    );

    
    uart_controller_rx #(
        .D_BIT(D_BIT),
        .SB_TICK(SB_TICK)
    ) U1 (
        .ckht(ckht),
        .rst(rst),
        .s_tick(s_tick),
        .rx(uart_rx),
        .rx_data(fifo_rx_data_in),
        .rx_done_tick(fifo_rx_wr)
    );

    
    fifo_rx #(
        .B(D_BIT),
        .W(FIFO_W)
    ) U2 (
        .ckht(ckht),
        .rst(rst),
        .wr_data(fifo_rx_data_in),
        .wr(fifo_rx_wr),
        .rd(fifo_rx_ena_rd),
        .rd_data(fifo_rx_data_out),
        .empty(fifo_rx_empty),
        .full(fifo_rx_full_wire)
    );

    
    uart_controller_tx #(
        .D_BIT(D_BIT),
        .SB_TICK(SB_TICK)
    ) U3 (
        .ckht(ckht),
        .rst(rst),
        .s_tick(s_tick),
        .tx_data(fifo_tx_data_out),
        .tx_fifo_empty(fifo_tx_empty),
        .tx_done_tick(fifo_tx_rd),
        .tx(uart_tx)
    );

    
    fifo_tx #(
        .B(D_BIT),
        .W(FIFO_W)
    ) U4 (
        .ckht(ckht),
        .rst(rst),
        .rd(fifo_tx_rd),
        .rd_data(fifo_tx_data_out),
        .empty(fifo_tx_empty),
        .wr(fifo_tx_ena_wr),
        .wr_data(fifo_tx_data_in),
        .full(fifo_tx_full)
    );

endmodule