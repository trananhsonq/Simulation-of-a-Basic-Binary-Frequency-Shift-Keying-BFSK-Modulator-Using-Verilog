// =============================================================
// Module   : bfsk_modulator_structural.v
// Function : BFSK Modulator — structural version
//            Instantiates the three sub-modules:
//              1. freq_control_unit   (FCU)
//              2. counter_divider_unit (CDU)
//              3. output_toggle_reg   (OTR)
//
//            Functionally equivalent to bfsk_modulator.v.
//            Use this version to understand the internal
//            signal flow between blocks.
//
// Wiring:
//   data_in -> FCU -> divisor -> CDU -> toggle_pulse -> OTR -> modulated_out
// =============================================================


// NOTE: This module is named 'bfsk_modulator' so it is a drop-in
//       replacement for bfsk_modulator.v.  Compile EITHER this file
//       OR bfsk_modulator.v — never both at the same time.
module bfsk_modulator (
    input  wire clk,
    input  wire rst,
    input  wire data_in,
    output wire modulated_out
);

    parameter F0_DIV = 8'd50;
    parameter F1_DIV = 8'd25;

    // ── Internal wires ─────────────────────────────────────────
    wire [7:0] divisor;         // FCU  -> CDU
    wire       toggle_pulse;    // CDU  -> OTR

    // ── Block 1 : Frequency Control Unit (FCU) ─────────────────
    freq_control_unit #(
        .F0_DIV (F0_DIV),
        .F1_DIV (F1_DIV)
    ) u_fcu (
        .data_bit (data_in),
        .divisor  (divisor)
    );

    // ── Block 2 : Counter / Divider Unit (CDU) ─────────────────
    counter_divider_unit u_cdu (
        .clk          (clk),
        .rst          (rst),
        .divisor      (divisor),
        .toggle_pulse (toggle_pulse)
    );

    // ── Block 3 : Output Toggle Register (OTR) ─────────────────
    output_toggle_reg u_otr (
        .clk          (clk),
        .rst          (rst),
        .toggle_pulse (toggle_pulse),
        .out          (modulated_out)
    );

endmodule  // bfsk_modulator (structural)
