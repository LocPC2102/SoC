`timescale 1ns / 1ps
`include "riscv_defs.vh"

module cpu_core (
    input  wire        hclk,
    input  wire        hresetn,        

    // Debug ports
    output wire [31:0] out_pc,
    output wire [31:0] out_alu_result,

    // AHB-Lite Master port
    output reg  [31:0] haddr,
    output reg  [31:0] hwdata,
    output reg         hwrite,
    output reg  [1:0]  htrans,
    output reg  [2:0]  hsize,
    input  wire [31:0] hrdata,
    input  wire        hready,

    // IMEM Interface
    output wire [31:0] imem_pc,
    input  wire [31:0] imem_instruction
);

    wire reset = ~hresetn;
    wire [31:0] current_pc;
    wire [31:0] fetched_instruction;

    wire [6:0]  opcode;
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm_out;

    wire [31:0] rs1_data_out;
    wire [31:0] rs2_data_out;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;

    wire        reg_write;
    wire        alu_src;
    wire [3:0]  alu_ctrl;
    wire        branch_sig;
    wire        take_br;
    wire [31:0] pc_target;

    wire        mem_write;
    wire        mem_read;
    wire        mem_to_reg;

    // Pipeline buffer gi? data phase cho chu k? sau c?a AHB-Lite
    reg [31:0] rs2_data_reg;
    always @(posedge hclk or posedge reset) begin
        if (reset) rs2_data_reg <= 32'h0;
        else if (!stall) rs2_data_reg <= rs2_data_out;
    end

    // M?ch phát hi?n yêu c?u truy c?p b? nh? hi?n t?i
    wire mem_access = mem_write || mem_read;
    
    // Tr?ng thái l?u xem chu k? tr??c CPU có ?ang phát Request Bus hay không
    reg mem_access_delay;
    always @(posedge hclk or posedge reset) begin
        if (reset) mem_access_delay <= 1'b0;
        else if (!stall) mem_access_delay <= mem_access;
    end

    // CPU Stall khi chu k? tr??c có phát request b? nh? mà Bus ch?a tr? v? HREADY=1
    wire stall = mem_access_delay && !hready;

    assign pc_target = current_pc + imm_out;
    assign take_br   = branch_sig & alu_zero;

    assign imem_pc             = current_pc;
    assign fetched_instruction = imem_instruction;

    assign out_pc         = current_pc;
    assign out_alu_result = alu_result;

    wire [31:0] writeback_data = mem_to_reg ? hrdata : alu_result;

    // Kh?i ?i?u khi?n Bus AHB-Lite Master chính xác theo Phase ki?n trúc
    always @(posedge hclk or posedge reset) begin
        if (reset) begin
            haddr  <= 32'h0;
            hwdata <= 32'h0;
            hwrite <= 1'b0;
            htrans <= 2'b00;    // IDLE
            hsize  <= 3'b010;   // 32-bit
        end else if (!stall) begin
            if (mem_access) begin
                haddr  <= alu_result;
                hwrite <= mem_write;
                htrans <= 2'b10;    // NONSEQ (Address Phase b?t ??u)
                hsize  <= 3'b010;
            end else begin
                haddr  <= 32'h0;
                hwrite <= 1'b0;
                htrans <= 2'b00;    // IDLE
                hsize  <= 3'b010;
            end
            // C?p nh?t Data Phase t? buffer chu k? tr??c
            hwdata <= rs2_data_reg;
        end else begin
            // N?u Bus ?ang Stall, b?t bu?c ph?i gi? nguyên Data Phase hi?n t?i ra ngoài Bus
            hwdata <= rs2_data_reg;
        end
    end

    control_unit my_control (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src(alu_src), .alu_ctrl(alu_ctrl),
        .branch(branch_sig), .mem_write(mem_write), .mem_read(mem_read), .mem_to_reg(mem_to_reg)
    );

    pc_logic pc_reg (
        .clk(hclk), .reset(reset), .pc_target(pc_target),
        .take_br(take_br), .stall(stall), .pc(current_pc)
    );

    decode my_decode (
        .instruction(fetched_instruction), .opcode(opcode),
        .rs1(rs1_addr), .rs2(rs2_addr), .rd(rd_addr), .funct3(funct3), .funct7(funct7)
    );

    imm_gen my_imm_gen (
        .instruction(fetched_instruction), .imm_out(imm_out)
    );

    assign alu_operand_b = alu_src ? imm_out : rs2_data_out;

    alu my_alu (
        .a(rs1_data_out), .b(alu_operand_b), .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );

    regfile my_regfile (
        .clk(hclk), .we(reg_write), .stall(stall),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .rd_data(writeback_data), .rs1_data(rs1_data_out), .rs2_data(rs2_data_out)
    );

endmodule