`timescale 1ns / 1ps

module ahb_to_apb (
    input  wire        hclk,
    input  wire        hresetn,

    // AHB Slave interface
    input  wire        hsel,
    input  wire [31:0] haddr,
    input  wire [31:0] hwdata,
    input  wire        hwrite,
    input  wire [1:0]  htrans,
    output reg         hreadyout,
    output wire [31:0] hrdata,

    // APB Master interface
    output reg         psel,
    output reg         penable,
    output reg         pwrite,
    output reg  [31:0] paddr,
    output reg  [31:0] pwdata,
    input  wire [31:0] prdata,
    input  wire        pready      // Thêm ngõ vào PREADY t? APB Bus Interconnect
);

    localparam ST_IDLE   = 2'b00;
    localparam ST_SETUP  = 2'b01;
    localparam ST_ACCESS = 2'b10;

    reg [1:0] state;
    reg [31:0] saved_addr;
    reg        saved_write;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            state       <= ST_IDLE;
            saved_addr  <= 32'h0;
            saved_write <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (hsel && htrans == 2'b10) begin
                        saved_addr  <= haddr;
                        saved_write <= hwrite;
                        state       <= ST_SETUP;
                    end
                end

                ST_SETUP: begin
                    state <= ST_ACCESS;
                end

                ST_ACCESS: begin
                    if (pready) begin // Ch? thoát tr?ng thái ACCESS khi Ngo?i vi th?c t? báo DONE (pready==1)
                        state <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    always @(*) begin
        hreadyout = 1'b1;
        psel      = 1'b0;
        penable   = 1'b0;
        pwrite    = 1'b0;
        paddr     = 32'h0;
        pwdata    = 32'h0;

        case (state)
            ST_IDLE: begin
                if (hsel && htrans == 2'b10)
                    hreadyout = 1'b0; 
            end

            ST_SETUP: begin
                hreadyout = 1'b0;     
                psel      = 1'b1;     
                penable   = 1'b0;
                paddr     = saved_addr;
                pwrite    = saved_write;
                pwdata    = hwdata;   
            end

            ST_ACCESS: begin
                psel      = 1'b1;     
                penable   = 1'b1;
                paddr     = saved_addr;
                pwrite    = saved_write;
                pwdata    = hwdata;
                // N?u ngo?i vi ch?a x? lý xong, ép hreadyout xu?ng 0 b?t CPU ch? ti?p
                hreadyout = pready; 
            end
            default: hreadyout = 1'b1;
        endcase
    end

    assign hrdata = prdata;

endmodule