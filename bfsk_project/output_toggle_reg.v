// =============================================================
// Module   : output_toggle_reg.v
// Function : Output Toggle Register (OTR)
//            Single D flip-flop. Inverts its stored value each
//            time a toggle_pulse is received from the CDU.
//            Produces a 50% duty-cycle square-wave carrier.
//
// Inputs:
//   clk          - System clock
//   rst          - Synchronous active-high reset
//   toggle_pulse - 1-cycle pulse from counter_divider_unit
//
// Outputs:
//   out  - BFSK square-wave output signal
// =============================================================

module output_toggle_reg (
    input  wire clk,
    input  wire rst,
    input  wire toggle_pulse,
    output reg  out
);

    always @(posedge clk) begin
        if (rst)
            out <= 1'b0;
        else if (toggle_pulse)
            out <= ~out;   // Invert output every half-period
        // else: hold current value
    end

endmodule
