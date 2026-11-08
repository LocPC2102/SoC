`timescale 1ns/1ps
module i2c_top_tb;
reg clk = 0, rst = 0, newd = 0, op;
reg [6:0] addr;
reg [7:0] din;
wire [7:0] dout;
wire busy, ack_err, done;

// DUT
i2c_top dut (
    .clk    (clk),
    .rst    (rst),
    .newd   (newd),
    .op     (op),
    .addr   (addr),
    .din    (din),
    .dout   (dout),
    .busy   (busy),
    .ack_err(ack_err),
    .done   (done)
);

// Clock: 100 MHz (period = 10 ns)

always #5 clk = ~clk;

// FIX: timeout watchdog - tránh wait(done) treo vô t?n

integer timeout;
task wait_done_timeout;
    begin
        timeout = 0;
        while (done !== 1'b1 && timeout < 5000000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        if (timeout >= 5000000)
            $display("[TIMEOUT] Transaction did not complete!");
    end
endtask

initial begin
    // ===== RESET =====
    rst  = 1;
    newd = 0;
    op   = 0;
    addr = 0;
    din  = 0;
    repeat(10) @(posedge clk);
    rst = 0;
    repeat(20) @(posedge clk);

    // =============================================

    // Transaction 1: WRITE 0xA5 to slave addr 0x48

    // =============================================

    @(posedge clk);
    newd = 1;
    op   = 0;           // write
    addr = 7'h48;
    din  = 8'hA5;
    @(posedge clk);
    newd = 0;
    wait_done_timeout;
    @(posedge clk);
    $display("[WR] addr=0x%02h  din=0x%02h  ack_err=%b", addr, din, ack_err);
    repeat(20) @(posedge clk);

    // =============================================

    // Transaction 2: READ from slave addr 0x48

    // =============================================

    @(posedge clk);
    newd = 1;
    op   = 1;           // read
    addr = 7'h48;
    @(posedge clk);
    newd = 0;
    wait_done_timeout;
    @(posedge clk);
    $display("[RD] addr=0x%02h  dout=0x%02h  ack_err=%b", addr, dout, ack_err);
    repeat(20) @(posedge clk);

    // =============================================

    // Transaction 3: WRITE 0x5A to slave addr 0x49

    // =============================================

    @(posedge clk);
    newd = 1;
    op   = 0;
    addr = 7'h49;
    din  = 8'h5A;
    @(posedge clk);
    newd = 0;
    wait_done_timeout;
    @(posedge clk);
    $display("[WR] addr=0x%02h  din=0x%02h  ack_err=%b", addr, din, ack_err);
    repeat(20) @(posedge clk);

    // =============================================

    // Transaction 4: READ from slave addr 0x49

    // =============================================

    @(posedge clk);
    newd = 1;
    op   = 1;
    addr = 7'h49;
    @(posedge clk);
    newd = 0;
    wait_done_timeout;
    @(posedge clk);
    $display("[RD] addr=0x%02h  dout=0x%02h  ack_err=%b", addr, dout, ack_err);
    repeat(50) @(posedge clk);
    $display("=== Simulation Complete ===");
    $stop;
end

endmodule