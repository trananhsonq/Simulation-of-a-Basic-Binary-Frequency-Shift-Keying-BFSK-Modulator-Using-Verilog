// =============================================================
// Module   : bfsk_modulator.v
// Function : Binary FSK Modulator — flat RTL version
//            All logic in a single always block.
//            Synthesizable, FPGA/ASIC ready.
//
// Operation:
//   Generates a square-wave output that toggles at frequency
//   f1 when data_in='1', or f0 when data_in='0'.
//
// Parameters:
//   F0_DIV  - Divisor for space frequency f0  (bit '0')
//   F1_DIV  - Divisor for mark  frequency f1  (bit '1')
//
// Frequency formula:
//   f_out = f_clk / (2 x FDIV)
//
// Example (50 MHz clock):
//   F0_DIV = 50  ->  f0 = 500 kHz
//   F1_DIV = 25  ->  f1 = 1 MHz
// =============================================================

module bfsk_modulator (
    input  wire clk,            // Master system clock
    input  wire rst,            // Synchronous active-high reset
    input  wire data_in,        // Serial binary data input
    output reg  modulated_out   // BFSK modulated square-wave output
);

    parameter F0_DIV = 8'd50;   // Space frequency divisor (bit '0')
    parameter F1_DIV = 8'd25;   // Mark  frequency divisor (bit '1')

    // ── Internal counter ───────────────────────────────────────
    reg [7:0] counter;

    // ── Sequential logic ───────────────────────────────────────
    always @(posedge clk) begin
        if (rst) begin
            counter       <= 8'd0;
            modulated_out <= 1'b0;

        end else begin

            if (data_in == 1'b1) begin
                // ── Mark frequency  f1 ───────────────────────
                if (counter >= F1_DIV - 8'd1) begin
                    counter       <= 8'd0;
                    modulated_out <= ~modulated_out;
                end else begin
                    counter <= counter + 8'd1;
                end

            end else begin
                // ── Space frequency f0 ───────────────────────
                if (counter >= F0_DIV - 8'd1) begin
                    counter       <= 8'd0;
                    modulated_out <= ~modulated_out;
                end else begin
                    counter <= counter + 8'd1;
                end
            end

        end
    end

endmodule
