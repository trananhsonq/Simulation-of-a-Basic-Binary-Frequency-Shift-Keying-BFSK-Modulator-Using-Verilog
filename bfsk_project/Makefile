# =============================================================
# Makefile — BFSK Modulator Project
# Tools: Icarus Verilog (iverilog), GTKWave (gtkwave)
#
# Targets:
#   make sim_flat    - Simulate flat (single-module) modulator
#   make sim_struct  - Simulate structural (sub-module) modulator
#   make sim_top     - Simulate full top-level system
#   make wave_flat   - Open flat modulator waveform
#   make wave_top    - Open top-level waveform
#   make all         - Run all three simulations
#   make clean       - Remove generated files
# =============================================================

.PHONY: all sim_flat sim_struct sim_top wave_flat wave_top clean help

all: sim_flat sim_struct sim_top

# ── Flat modulator testbench ──────────────────────────────────
sim_flat:
	@echo "\n>>> [1/3] Flat BFSK Modulator"
	iverilog -o sim_flat_out \
		bfsk_modulator.v \
		bfsk_modulator_tb.v
	vvp sim_flat_out
	@echo ">>> VCD: bfsk_modulator.vcd"

# ── Structural modulator testbench ───────────────────────────
sim_struct:
	@echo "\n>>> [2/3] Structural BFSK Modulator"
	iverilog -o sim_struct_out \
		freq_control_unit.v \
		counter_divider_unit.v \
		output_toggle_reg.v \
		bfsk_modulator_structural.v \
		bfsk_modulator_tb.v
	vvp sim_struct_out
	@echo ">>> (Functionally identical to flat version)"

# ── Top-level system testbench ────────────────────────────────
sim_top:
	@echo "\n>>> [3/3] Top-Level System (DIM + Modulator)"
	iverilog -o sim_top_out \
		data_input_module.v \
		bfsk_modulator.v \
		bfsk_top.v \
		bfsk_top_tb.v
	vvp sim_top_out
	@echo ">>> VCD: bfsk_top.vcd"

# ── Waveform viewers ─────────────────────────────────────────
wave_flat:
	gtkwave bfsk_modulator.vcd &

wave_top:
	gtkwave bfsk_top.vcd &

# ── Clean ────────────────────────────────────────────────────
clean:
	rm -f *.vcd sim_flat_out sim_struct_out sim_top_out

# ── Help ─────────────────────────────────────────────────────
help:
	@echo "BFSK Modulator Project — Makefile targets:"
	@echo "  make sim_flat    Flat RTL modulator testbench"
	@echo "  make sim_struct  Structural (sub-module) testbench"
	@echo "  make sim_top     Full system with Data Input Module"
	@echo "  make wave_flat   Open bfsk_modulator.vcd in GTKWave"
	@echo "  make wave_top    Open bfsk_top.vcd in GTKWave"
	@echo "  make clean       Remove build artefacts"
