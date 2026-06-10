// =============================================================
// Module   : freq_control_unit.v
// Function : Frequency Control Unit (FCU)
//            Combinational 2-to-1 MUX — selects the counter
//            divisor based on the incoming data bit.
//
//  data_bit = '1'  ->  divisor = F1_DIV  (mark  frequency)
//  data_bit = '0'  ->  divisor = F0_DIV  (space frequency)
//
// Parameters:
//   F0_DIV : Clock divisor for space freq f0  (default 50)
//   F1_DIV : Clock divisor for mark  freq f1  (default 25)
//
// Example (50 MHz clock):
//   F0_DIV = 50  ->  f0 = 50e6 / (2*50) = 500 kHz
//   F1_DIV = 25  ->  f1 = 50e6 / (2*25) = 1   MHz
// =============================================================

module freq_control_unit (
    input  wire       data_bit,   // Current serial data bit
    output reg  [7:0] divisor     // Selected clock divisor
);

    // Carrier frequency divisor constants
    parameter F0_DIV = 8'd50;   // Space  (bit '0')
    parameter F1_DIV = 8'd25;   // Mark   (bit '1')

    // Purely combinational selection
    always @(*) begin
        if (data_bit == 1'b1)
            divisor = F1_DIV;
        else
            divisor = F0_DIV;
    end

endmodule
