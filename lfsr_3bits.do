vlib work

# Compile all Verilog modules in lfsr_3bits.v to working dir;

vlog -timescale 1ps/1ps lfsr_3bits.v

vsim lfsr_3bits

# Log all signals and add some signals to waveform window.
log {/*}

add wave {/*}

force {clock} 0 0, 1 50ps -r 100ps

# Load Seed
force {load_seed} 2#1
force {enable} 2#1
force {seed} 2#101
run 100ps

# Run
force {load_seed} 2#0
run 500ps