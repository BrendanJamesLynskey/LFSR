# synth_all.tcl — Batch synthesis for LFSR modules
# Target: Artix-7 xc7a35tcpg236-1 | Clock: 125 MHz (Gigabit Ethernet)
# Brendan Lynskey 2025

set_param general.maxThreads 2

set part     "xc7a35tcpg236-1"
set clk_ns   8.0
set log_dir  "synthesis_logs"
file mkdir $log_dir

# List of {top_module source_files}
# lfsr_prbs instantiates lfsr_fibonacci, so include both source files
set modules {
    {lfsr_fibonacci {rtl/lfsr_pkg.sv rtl/lfsr_fibonacci.sv}}
    {lfsr_galois    {rtl/lfsr_pkg.sv rtl/lfsr_galois.sv}}
    {lfsr_prbs      {rtl/lfsr_pkg.sv rtl/lfsr_fibonacci.sv rtl/lfsr_prbs.sv}}
    {lfsr_scrambler {rtl/lfsr_pkg.sv rtl/lfsr_scrambler.sv}}
}

set summary {}

foreach mod $modules {
    set top   [lindex $mod 0]
    set srcs  [lindex $mod 1]

    puts "=========================================="
    puts "Synthesising: $top"
    puts "=========================================="

    create_project -in_memory -part $part

    foreach src $srcs {
        read_verilog -sv $src
    }

    read_xdc synth/clock.xdc

    synth_design -top $top -part $part
    opt_design
    place_design
    route_design

    # Reports
    report_utilization -file "$log_dir/${top}_utilization.rpt"
    report_timing_summary -file "$log_dir/${top}_timing.rpt"

    # Extract key metrics
    set util_rpt [report_utilization -return_string]
    set timing_rpt [report_timing_summary -return_string]

    # Parse LUTs
    set luts "?"
    if {[regexp {Slice LUTs\s*\|\s*(\d+)} $util_rpt -> val]} { set luts $val }
    # Parse FFs
    set ffs "?"
    if {[regexp {Slice Registers\s*\|\s*(\d+)} $util_rpt -> val]} { set ffs $val }
    # Parse BRAM
    set bram "0"
    if {[regexp {Block RAM Tile\s*\|\s*(\S+)} $util_rpt -> val]} { set bram $val }
    # Parse DSP
    set dsp "0"
    if {[regexp {DSPs\s*\|\s*(\d+)} $util_rpt -> val]} { set dsp $val }

    # Parse WNS for Fmax — Fmax = 1000 / (period - WNS)
    set fmax "?"
    if {[regexp {\n\s+(-?[0-9]+\.[0-9]+)\s+(-?[0-9]+\.[0-9]+)\s+\d+\s+\d+\s+} $timing_rpt -> wns_val tns_val]} {
        set wns [expr {double($wns_val)}]
        set fmax [format "%.1f" [expr {1000.0 / ($clk_ns - $wns)}]]
    }

    lappend summary [list $top $luts $ffs $bram $dsp $fmax]

    puts "  LUTs=$luts  FFs=$ffs  BRAM=$bram  DSP=$dsp  Fmax=$fmax MHz"

    close_project
}

puts ""
puts "=========================================="
puts "LFSR Synthesis Summary"
puts "=========================================="
puts [format "%-25s %6s %6s %6s %6s %10s" "Module" "LUTs" "FFs" "BRAM" "DSP" "Fmax(MHz)"]
puts [string repeat "-" 65]
foreach entry $summary {
    puts [format "%-25s %6s %6s %6s %6s %10s" {*}$entry]
}
puts ""
puts "Target: $part | Clock: [expr {1000.0 / $clk_ns}] MHz ($clk_ns ns)"
