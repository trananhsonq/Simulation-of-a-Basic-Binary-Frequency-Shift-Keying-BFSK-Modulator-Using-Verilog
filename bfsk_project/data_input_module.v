// =============================================================
// Module   : data_input_module.v
// Function : Parallel-to-Serial Data Input Module
//            Accepts an 8-bit parallel byte, serialises it
//            MSB-first at a configurable bit rate, and drives
//            the serial_out line for the BFSK modulator.
//
// Inputs:
//   clk           - System clock
//   rst           - Synchronous active-high reset
//   parallel_data - 8-bit data byte to transmit
//   load          - Active-high 1-cycle load/start pulse
//   bit_period    - Number of clock cycles per bit
//                   (e.g. 2500 @ 50 MHz = 50 µs/bit = 20 kbps)
//
// Outputs:
//   serial_out    - MSB-first serial data stream
//   tx_busy       - High while transmitting
//   tx_done       - 1-cycle high pulse when all 8 bits sent
//
// State machine:
//   IDLE  -> TRANSMIT (on load) -> IDLE (after 8 bits)
// =============================================================

module data_input_module (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  parallel_data,
    input  wire        load,
    input  wire [15:0] bit_period,
    output reg         serial_out,
    output reg         tx_busy,
    output reg         tx_done
);

    // ── State encoding ─────────────────────────────────────────
    localparam IDLE     = 1'b0;
    localparam TRANSMIT = 1'b1;

    // ── Internal registers ─────────────────────────────────────
    reg        state;
    reg [7:0]  shift_reg;       // Shift register holding current byte
    reg [15:0] bit_timer;       // Counts clk cycles within one bit period
    reg [3:0]  bit_index;       // Which bit we are currently sending (0=MSB)

    // ── Sequential logic ───────────────────────────────────────
    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            shift_reg  <= 8'd0;
            bit_timer  <= 16'd0;
            bit_index  <= 4'd0;
            serial_out <= 1'b0;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;
        end else begin

            // Default: clear single-cycle signals
            tx_done <= 1'b0;

            case (state)

                // ── IDLE ─────────────────────────────────────
                IDLE: begin
                    serial_out <= 1'b0;
                    tx_busy    <= 1'b0;

                    if (load) begin
                        shift_reg  <= parallel_data;          // Latch input
                        serial_out <= parallel_data[7];       // Output MSB immediately
                        bit_timer  <= 16'd0;
                        bit_index  <= 4'd0;
                        tx_busy    <= 1'b1;
                        state      <= TRANSMIT;
                    end
                end

                // ── TRANSMIT ─────────────────────────────────
                TRANSMIT: begin
                    if (bit_timer >= bit_period - 1) begin
                        // Current bit period expired — advance to next bit
                        bit_timer <= 16'd0;

                        if (bit_index == 4'd7) begin
                            // All 8 bits sent → return to IDLE
                            state      <= IDLE;
                            tx_busy    <= 1'b0;
                            tx_done    <= 1'b1;
                            serial_out <= 1'b0;
                            bit_index  <= 4'd0;
                        end else begin
                            // Shift left and output next bit
                            shift_reg  <= {shift_reg[6:0], 1'b0};
                            serial_out <= shift_reg[6];   // Uses old value (non-blocking)
                            bit_index  <= bit_index + 4'd1;
                        end

                    end else begin
                        // Still within current bit period — hold output
                        bit_timer <= bit_timer + 16'd1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
