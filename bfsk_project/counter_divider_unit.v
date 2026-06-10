// =============================================================
// Module   : counter_divider_unit.v
// Function : Counter / Divider Unit (CDU)
//            Synchronous N-modulo counter. Counts rising clock
//            edges and asserts a one-cycle toggle_pulse when
//            the counter reaches the selected divisor value.
//
// Inputs:
//   clk         - System clock
//   rst         - Synchronous active-high reset
//   divisor     - 8-bit threshold from FCU (N0 or N1)
//
// Outputs:
//   toggle_pulse - 1-cycle high pulse at every counter wrap
//
// Output frequency:
//   f_out = f_clk / (2 * divisor)   [one pulse per half-period]
// =============================================================

module counter_divider_unit (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] divisor,
    output reg        toggle_pulse
);

    reg [7:0] counter;  // 8-bit free-running counter

    always @(posedge clk) begin
        if (rst) begin
            counter      <= 8'd0;
            toggle_pulse <= 1'b0;
        end else begin
            toggle_pulse <= 1'b0;           // default: no pulse

            if (counter >= divisor - 8'd1) begin
                counter      <= 8'd0;       // reset counter
                toggle_pulse <= 1'b1;       // assert pulse for 1 cycle
            end else begin
                counter <= counter + 8'd1;  // keep counting
            end
        end
    end

endmodule
