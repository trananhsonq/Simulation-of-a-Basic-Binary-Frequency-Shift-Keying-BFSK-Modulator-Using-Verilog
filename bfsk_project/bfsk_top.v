// =============================================================
// Module   : bfsk_top.v
// Function : Top-Level Integration Module
//            Connects the Data Input Module (parallel->serial)
//            with the BFSK Modulator.
//
//            ┌─────────────────────────────────────────────────┐
//            │               bfsk_top                          │
//            │                                                 │
//  clk  ─────┤──►  data_input_module  ──serial──►  bfsk_mod ──┤──► modulated_out
//  rst  ─────┤                                                 │
//  data ─────┤   (8-bit parallel in)   (1-bit serial)         │
//  load ─────┤                                                 │
//            └─────────────────────────────────────────────────┘
//
// Parameters:
//   F0_DIV     - Space frequency divisor (default 50  -> 500 kHz @ 50 MHz)
//   F1_DIV     - Mark  frequency divisor (default 25  -> 1 MHz   @ 50 MHz)
//   BIT_PERIOD - Clock cycles per bit    (default 2500 -> 20 kbps @ 50 MHz)
// =============================================================


module bfsk_top (
    input  wire        clk,            // Master clock (50 MHz)
    input  wire        rst,            // Synchronous active-high reset
    input  wire [7:0]  parallel_data,  // 8-bit byte to transmit
    input  wire        load,           // Pulse high to start transmission
    output wire        modulated_out,  // BFSK modulated output
    output wire        tx_busy,        // High during transmission
    output wire        tx_done         // 1-cycle pulse when byte is sent
);

    parameter F0_DIV     = 8'd50;        // Space divisor  (bit '0')
    parameter F1_DIV     = 8'd25;        // Mark  divisor  (bit '1')
    parameter BIT_PERIOD = 16'd2500;     // Clk cycles per bit

    // ── Internal wire: serial data from DIM to modulator ───────
    wire serial_data;

    // ── Block 1 : Data Input Module (Parallel-to-Serial) ───────
    data_input_module u_dim (
        .clk           (clk),
        .rst           (rst),
        .parallel_data (parallel_data),
        .load          (load),
        .bit_period    (BIT_PERIOD),
        .serial_out    (serial_data),
        .tx_busy       (tx_busy),
        .tx_done       (tx_done)
    );

    // ── Block 2 : BFSK Modulator ────────────────────────────────
    bfsk_modulator #(
        .F0_DIV (F0_DIV),
        .F1_DIV (F1_DIV)
    ) u_mod (
        .clk           (clk),
        .rst           (rst),
        .data_in       (serial_data),
        .modulated_out (modulated_out)
    );

endmodule
