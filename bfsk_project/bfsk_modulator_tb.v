// =============================================================
// Module   : bfsk_modulator_tb.v
// Function : Testbench for bfsk_modulator (flat version)
//            Tests individual bit transitions and verifies
//            the correct carrier frequency is produced.
//
// Test sequence:  0  1  0  1  1  0   (2000 ns each bit)
//   Bit '0'  ->  f0 = 500 kHz  (toggle every 50 cycles)
//   Bit '1'  ->  f1 = 1 MHz    (toggle every 25 cycles)
// =============================================================

`timescale 1ns / 1ps

module bfsk_modulator_tb;

    // ── DUT signal declarations ────────────────────────────────
    reg  clk;
    reg  rst;
    reg  data_in;
    wire modulated_out;

    // ── DUT instantiation ──────────────────────────────────────
    bfsk_modulator #(
        .F0_DIV (8'd50),
        .F1_DIV (8'd25)
    ) u_dut (
        .clk           (clk),
        .rst           (rst),
        .data_in       (data_in),
        .modulated_out (modulated_out)
    );

    // ── Clock: 50 MHz, period = 20 ns ──────────────────────────
    initial  clk = 1'b0;
    always   #10 clk = ~clk;

    // ── VCD waveform dump ──────────────────────────────────────
    initial begin
        $timeformat(-9, 0, " ns", 10);  // Display time in ns
        $dumpfile("bfsk_modulator.vcd");
        $dumpvars(0, bfsk_modulator_tb);
    end

    // ── Console monitor ────────────────────────────────────────
    initial begin
        $monitor("TIME=%0t ns | rst=%b | data_in=%b | modulated_out=%b",
                 $time, rst, data_in, modulated_out);
    end

    // ── Test stimulus ──────────────────────────────────────────
    initial begin
        $display("=== BFSK Modulator Testbench Start ===");

        // 1) Apply synchronous reset for 2 clock cycles
        rst      = 1'b1;
        data_in  = 1'b0;
        @(posedge clk);
        @(posedge clk);
        rst = 1'b0;

        // 2) Transmit bit sequence: 0, 1, 0, 1, 1, 0
        //    Each bit held for 2000 ns  = 100 clock cycles

        // Bit '0'  ->  expect f0 = 500 kHz on modulated_out
        data_in = 1'b0;  #2000;

        // Bit '1'  ->  expect f1 = 1 MHz  on modulated_out
        data_in = 1'b1;  #2000;

        // Bit '0'
        data_in = 1'b0;  #2000;

        // Bit '1'
        data_in = 1'b1;  #2000;

        // Bit '1'
        data_in = 1'b1;  #2000;

        // Bit '0'
        data_in = 1'b0;  #2000;

        // 3) Apply reset again mid-stream
        rst = 1'b1;  #100;
        rst = 1'b0;

        // 4) Continue with a few more bits
        data_in = 1'b1;  #2000;
        data_in = 1'b0;  #2000;

        $display("=== BFSK Modulator Testbench End ===");
        $finish;
    end

    // ── Automated frequency check (measures posedge-to-posedge period) ─
    integer toggle_count;
    real    last_edge_ns;
    real    curr_edge_ns;
    real    period_ns;

    initial begin
        toggle_count  = 0;
        last_edge_ns  = 0.0;
    end

    always @(posedge modulated_out) begin
        curr_edge_ns = $realtime;   // ns (timescale 1ns/1ps)
        if (last_edge_ns > 0.0) begin
            period_ns = curr_edge_ns - last_edge_ns;
            $display("  [CHECK] t=%.0f ns | Full-period=%.0f ns | f_out=%.0f kHz | data_in=%b",
                curr_edge_ns, period_ns,
                (period_ns > 0) ? (1_000_000.0 / period_ns) : 0.0,
                data_in);
        end
        last_edge_ns = curr_edge_ns;
        toggle_count = toggle_count + 1;
    end

endmodule
