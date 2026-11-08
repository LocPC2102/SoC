`timescale 1ns / 1ps
module baud_rate_generator #(
    parameter N = 6,    // ceil(log2(54)) = 6 bits cho 100MHz
    parameter M = 54    // 100MHz / (115200 * 16) = 54
)(
    input  wire ckht,
    input  wire rst,
    output wire tick
);
    reg [N-1:0] r_r;
    wire [N-1:0] r_n;

    always @(posedge ckht or posedge rst) begin
        if (rst == 1'b1)
            r_r <= {N{1'b0}};
        else
            r_r <= r_n;
    end

    assign r_n   = (r_r == (M - 1)) ? {N{1'b0}} : (r_r + 1'b1);
    assign tick  = (r_r == (M - 1)) ? 1'b1 : 1'b0;
endmodule