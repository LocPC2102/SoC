`timescale 1ns / 1ps

module tb_soc_top;

    // ---- Inputs ----
    reg clk;
    reg reset;
    reg uart_rx;
    reg spi_miso;

    // ---- Outputs ----
    wire uart_tx;
    wire spi_sclk;
    wire spi_cs_n;
    wire spi_mosi;
    wire [31:0] out_pc;
    wire [31:0] out_alu_result;

    // ---- Inouts ----
    wire i2c_sda;
    wire i2c_scl;

    // Pull-up resistors cho bus I2C (chu?n open-drain)
    assign i2c_sda = 1'bz;

    // ---- UUT (Unit Under Test) ----
    soc_top uut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .spi_sclk(spi_sclk),
        .spi_cs_n(spi_cs_n),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .i2c_sda(i2c_sda),
        .i2c_scl(i2c_scl),
        .out_pc(out_pc),
        .out_alu_result(out_alu_result)
    );

    // ---- T?o xung Clock t?n s? 100MHz (Chu k? 10ns) ----
    always #5 clk = ~clk;

    // ---- K?ch b?n Test chính ----
    initial begin
        // Kh?i t?o tr?ng thái ban ??u
        clk = 0;
        reset = 1;
        uart_rx = 1;     // UART IDLE là m?c cao
        spi_miso = 0;

        $display("=================================================");
        $display("STARTING MINI SOC SIMULATION...");
        $display("=================================================");

        // Gi? reset trong 5 chu k? clock (50ns)
        #50;
        reset = 0;
        $display("[TB] Reset De-asserted t?i th?i ?i?m %t", $time);

        // Ch? ch??ng trình ch?y qua các l?nh
        // Vì ?ây là c?u trúc Bus AHB có chèn chu k? ch? (Stall) ??ng, ta s? ??i t?m 2000ns
        #2000;

        $display("=================================================");
        $display("SIMULATION TIMEOUT REACHED");
        $display("Ki?m tra sóng d?ng sóng (Waveform) trên công c? mô ph?ng nhé!");
        $display("=================================================");
        $finish;
    end

    // ---- Kh?i Monitor: In tr?ng thái th?c thi c?a CPU ra màn hình Console ----
    always @(posedge clk) begin
        if (!reset) begin
            // Ch? in log khi PC thay ??i ?? tránh tràn ng?p màn hình text gi?ng nhau khi b? Stall
            if (uut.u_cpu.stall) begin
                $display("TIME: %t | PC: 0x%h | [BUS STALL ACTIVE] Ch? Bus ph?n h?i...", $time, out_pc);
            end else begin
                $display("TIME: %t | PC: 0x%h | Instr: 0x%h | ALU Result: 0x%h", 
                         $time, out_pc, uut.u_cpu.fetched_instruction, out_alu_result);
            end

            // Theo dõi n?u CPU ghi trúng l?nh truy?n UART thành công
            if (uut.u_bridge.state == 2'b10 && uut.paddr == 32'h40000000 && uut.pwrite && uut.penable && uut.pready) begin
                $display(">>> [SUCCESS] CPU ?ã ghi ký t? '%c' (0x%h) vào UART TX thành công!", uut.pwdata[7:0], uut.pwdata[7:0]);
            end
        end
    end

endmodule