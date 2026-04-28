# ####################################################################

#  Created by Encounter(R) RTL Compiler v12.10-s012_1 on Tue Apr 28 21:51:39 +0600 2026

# ####################################################################

set sdc_version 1.7

set_units -capacitance 1000.0fF
set_units -time 1000.0ps

# Set the current design
current_design eigen_top

create_clock -name "clk" -add -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_dont_use [get_lib_cells tsl18fs120_scl_ss/adiode]
set_dont_use [get_lib_cells tsl18fs120_scl_ss/bh01d1]
set_dont_use [get_lib_cells tsl18fs120_scl_ss/cload1]
