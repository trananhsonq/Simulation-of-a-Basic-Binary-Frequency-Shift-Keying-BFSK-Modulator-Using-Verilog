# BFSK Modulator — Verilog Project

Binary Frequency Shift Keying (BFSK) modulator implemented in
synthesisable Verilog HDL with a parallel-to-serial data input
module and full simulation testbenches.

---

## File Map

```
bfsk_project/
│
├── RTL Source (synthesisable)
│   ├── freq_control_unit.v          Block 1 – FCU: divisor MUX
│   ├── counter_divider_unit.v       Block 2 – CDU: N-modulo counter
│   ├── output_toggle_reg.v          Block 3 – OTR: toggle flip-flop
│   ├── data_input_module.v          Input  – parallel-to-serial converter
│   ├── bfsk_modulator.v             Flat single-module RTL (recommended)
│   ├── bfsk_modulator_structural.v  Structural version (FCU+CDU+OTR)
│   └── bfsk_top.v                   Top-level (DIM + Modulator)
│
├── Testbenches (simulation only)
│   ├── bfsk_modulator_tb.v          Tests flat/structural modulator
│   └── bfsk_top_tb.v                Tests full system (4 bytes + reset)
│
└── Makefile
```

---

## Parameters

| Parameter  | Default | Description                             |
|------------|--------:|-----------------------------------------|
| F0_DIV     | 50      | Space freq divisor — bit '0'            |
| F1_DIV     | 25      | Mark  freq divisor — bit '1'            |
| BIT_PERIOD | 2500    | Clock cycles per bit (top-level only)   |

**Frequency formula:**  `f_out = f_clk / (2 × FDIV)`

With 50 MHz clock:
- F0_DIV = 50 → f0 = **500 kHz**  (space, bit '0')
- F1_DIV = 25 → f1 = **1 MHz**    (mark,  bit '1')

---

## Quick Start

```bash
# Install Icarus Verilog (Ubuntu/Debian)
sudo apt install iverilog gtkwave

# Run all simulations
make all

# Or run individually
make sim_flat    # flat RTL modulator
make sim_struct  # structural sub-module version
make sim_top     # full system with data input module

# View waveforms
make wave_flat
make wave_top
```

---

## Module Descriptions

### `bfsk_modulator.v`
Flat RTL implementation. Single `always @(posedge clk)` block.
Use this for synthesis and simulation.

### `bfsk_modulator_structural.v`
Hierarchical version that instantiates FCU, CDU, and OTR sub-modules.
Same interface and behaviour as the flat version.
Use this to study the internal block decomposition.

> **Note:** Compile either `bfsk_modulator.v` OR `bfsk_modulator_structural.v`,
> never both at the same time (same module name `bfsk_modulator`).

### `data_input_module.v`
Parallel-to-serial converter.
- Accepts an 8-bit byte on `parallel_data`
- Pulse `load` to start transmission
- Outputs MSB-first on `serial_out`
- `tx_busy` stays high during transmission
- `tx_done` pulses for one cycle when done

### `bfsk_top.v`
Top-level integration module.
Connects `data_input_module` → `bfsk_modulator`.

---

## Simulation Results (verified)

| data_in | Divisor | Output Frequency |
|---------|---------|-----------------|
| '0'     | N0 = 50 | 500 kHz         |
| '1'     | N1 = 25 | 1 MHz           |

Top-level bytes transmitted in `bfsk_top_tb.v`:

| Byte | Binary     | Notes            |
|------|------------|------------------|
| 0xA5 | 1010_0101  | Alternating       |
| 0xFF | 1111_1111  | All mark (f1)     |
| 0x00 | 0000_0000  | All space (f0)    |
| 0xB6 | 1011_0110  | Mixed pattern     |
| 0xCC | 1100_1100  | After reset test  |
