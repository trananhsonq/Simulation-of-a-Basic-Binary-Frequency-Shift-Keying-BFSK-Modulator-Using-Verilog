// =============================================================
// Module   : bfsk_top_tb.v
// Function : Testbench for bfsk_top (full system)
//            Sends multiple 8-bit bytes through the
//            data_input_module and verifies BFSK modulation.
//
// Test bytes:
//   Byte 1: 0xA5 = 1010_0101  (alternating 1s and 0s)
//   Byte 2: 0xFF = 1111_1111  (all mark frequency)
//   Byte 3: 0x00 = 0000_0000  (all space frequency)
//   Byte 4: 0xB6 = 1011_0110  (mixed pattern)
//
// BIT_PERIOD = 100 cycles (shortened for simulation speed)
//   @ 50 MHz -> 2 µs per bit (500 kbps)
// =============================================================

`timescale 1ns / 1ps

module bfsk_top_tb;

    // ── DUT signal declarations ────────────────────────────────
    reg         clk;
    reg         rst;
    reg  [7:0]  parallel_data;
    reg         load;
    wire        modulated_out;
    wire        tx_busy;
    wire        tx_done;

    // ── DUT instantiation ──────────────────────────────────────
    // Use BIT_PERIOD=100 for faster simulation
    bfsk_top #(
        .F0_DIV     (8'd50),
        .F1_DIV     (8'd25),
        .BIT_PERIOD (16'd100)
    ) u_dut (
        .clk           (clk),
        .rst           (rst),
        .parallel_data (parallel_data),
        .load          (load),
        .modulated_out (modulated_out),
        .tx_busy       (tx_busy),
        .tx_done       (tx_done)
    );

    // ── Clock: 50 MHz, period = 20 ns ──────────────────────────
    initial  clk = 1'b0;
    always   #10 clk = ~clk;

    // ── VCD waveform dump ──────────────────────────────────────
    initial begin
        $dumpfile("bfsk_top.vcd");
        $dumpvars(0, bfsk_top_tb);
    end

    // ── Console monitor ────────────────────────────────────────
    initial begin
        $monitor("TIME=%0t ns | load=%b | busy=%b | done=%b | out=%b",
                 $time, load, tx_busy, tx_done, modulated_out);
    end

    // ── Task: send one byte and wait for completion ─────────────
    task send_byte;
        input [7:0] byte_val;
        begin
            $display("\n--- Sending byte: 0x%02X (%08b) ---", byte_val, byte_val);
            @(negedge clk);         // Align to negedge for safe setup
            parallel_data = byte_val;
            load          = 1'b1;
            @(posedge clk);         // Load latches on this edge
            @(negedge clk);
            load          = 1'b0;

            // Wait for transmission complete
            @(posedge tx_done);
            $display("--- Byte 0x%02X transmission done at t=%0t ns ---", byte_val, $time);
            #200;                   // Small gap between bytes
        end
    endtask

    // ── Test stimulus ──────────────────────────────────────────
    initial begin
        $display("========================================");
        $display("  BFSK Top-Level Testbench Start");
        $display("  F0_DIV=50 F1_DIV=25 BIT_PERIOD=100");
        $display("========================================");

        // 1) Initialise
        rst           = 1'b1;
        load          = 1'b0;
        parallel_data = 8'h00;
        @(posedge clk);
        @(posedge clk);
        rst = 1'b0;
        #50;

        // 2) Send four different bytes
        send_byte(8'hA5);   // 1010_0101
        send_byte(8'hFF);   // 1111_1111  (all mark)
        send_byte(8'h00);   // 0000_0000  (all space)
        send_byte(8'hB6);   // 1011_0110

        // 3) Test reset during active transmission
        $display("\n--- Testing mid-transmission reset ---");
        parallel_data = 8'h55;
        load          = 1'b1;
        @(posedge clk);
        load = 1'b0;
        #500;                   // Wait partway through
        rst  = 1'b1;
        @(posedge clk);
        rst  = 1'b0;
        $display("    Reset asserted and deasserted.");
        #200;

        // 4) Resume normal operation after reset
        send_byte(8'hCC);   // 1100_1100

        $display("\n========================================");
        $display("  BFSK Top-Level Testbench Complete");
        $display("========================================");
        $finish;
    end

endmodule
