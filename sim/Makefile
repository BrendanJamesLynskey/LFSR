# Brendan Lynskey 2025
# LFSR — Simulation Makefile

IVERILOG = iverilog -g2012 -Wall
VVP = vvp

RTL_DIR = ../rtl
TB_DIR = ../tb

.PHONY: all clean fibonacci galois prbs scrambler

all: fibonacci galois prbs scrambler

fibonacci:
	$(IVERILOG) -o tb_fibonacci.vvp -I$(RTL_DIR) $(RTL_DIR)/lfsr_pkg.sv $(RTL_DIR)/lfsr_fibonacci.sv $(TB_DIR)/tb_lfsr_fibonacci.sv
	$(VVP) tb_fibonacci.vvp

galois:
	$(IVERILOG) -o tb_galois.vvp -I$(RTL_DIR) $(RTL_DIR)/lfsr_pkg.sv $(RTL_DIR)/lfsr_galois.sv $(TB_DIR)/tb_lfsr_galois.sv
	$(VVP) tb_galois.vvp

prbs:
	$(IVERILOG) -o tb_prbs.vvp -I$(RTL_DIR) $(RTL_DIR)/lfsr_pkg.sv $(RTL_DIR)/lfsr_fibonacci.sv $(RTL_DIR)/lfsr_prbs.sv $(TB_DIR)/tb_lfsr_prbs.sv
	$(VVP) tb_prbs.vvp

scrambler:
	$(IVERILOG) -o tb_scrambler.vvp -I$(RTL_DIR) $(RTL_DIR)/lfsr_pkg.sv $(RTL_DIR)/lfsr_scrambler.sv $(TB_DIR)/tb_lfsr_scrambler.sv
	$(VVP) tb_scrambler.vvp

clean:
	rm -f *.vvp *.vcd
