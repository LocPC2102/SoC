module regfile(
    input  wire        clk,
    input  wire        we,
    input  wire        stall,      
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);
    reg [31:0] registers [31:0];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'h0;
    end

    assign rs1_data = (rs1_addr == 5'b0) ? 32'h0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'h0 : registers[rs2_addr];

    always @(posedge clk) begin
        if (we && !stall && rd_addr != 5'b0)  
            registers[rd_addr] <= rd_data;
    end
endmodule