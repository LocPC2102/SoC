`timescale 1ns / 1ps
module apb_slave_i2c (
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [31:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output wire        PREADY,
    inout  wire        i2c_sda,
    output wire        i2c_scl
);
    // ---- Register map chu?n hóa ----
    localparam OFFSET_TXDATA  = 12'h000; // W : [7:0] data ghi xu?ng slave
    localparam OFFSET_RXDATA  = 12'h004; // R : [7:0] data ??c t? slave
    localparam OFFSET_STATUS  = 12'h008; // R : [0]BUSY [1]DONE [2]ACK_ERR
    localparam OFFSET_CONTROL = 12'h00C; // W : [6:0]ADDR [7]OP [8]NEWD

    reg [7:0] tx_data_reg;
    reg [6:0] addr_reg;
    reg       op_reg;
    reg       newd_reg;

    wire [7:0] dout_wire;
    wire       busy_wire;
    wire       ack_err_wire;
    wire       done_wire;

    i2c_top u_i2c (
        .clk    (PCLK),
        .rst    (~PRESETn),
        .newd   (newd_reg),
        .op     (op_reg),
        .addr   (addr_reg),
        .din    (tx_data_reg),
        .dout   (dout_wire),
        .busy   (busy_wire),
        .ack_err(ack_err_wire),
        .done   (done_wire),
        .sda    (i2c_sda),
        .scl    (i2c_scl)
    );

    assign PREADY = 1'b1;

    // ---- APB Write ----
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_data_reg <= 8'h0;
            addr_reg    <= 7'h0;
            op_reg      <= 1'b0;
            newd_reg    <= 1'b0;
        end else begin
            newd_reg <= 1'b0; // pulse 1 cycle
            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR[11:0])
                    OFFSET_TXDATA:  tx_data_reg <= PWDATA[7:0];
                    OFFSET_CONTROL: begin
                        addr_reg <= PWDATA[6:0];
                        op_reg   <= PWDATA[7];
                        newd_reg <= PWDATA[8]; // pulse start
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
                OFFSET_RXDATA: PRDATA = {24'h0, dout_wire};
                OFFSET_STATUS: PRDATA = {29'h0, ack_err_wire,
                                                  done_wire,
                                                  busy_wire};
                default:       PRDATA = 32'h0;
            endcase
        end
    end

endmodule