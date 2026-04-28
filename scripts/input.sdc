# =======================================================
# SDC for SCL 180nm - Target: 10 MHz (100ns)
# =======================================================

# 1. Define Clock (100ns period)
create_clock -name clk -period 100.0 [get_ports clk]
set_clock_uncertainty 2.0 [get_clocks clk]

# 2. Input/Output Delays 
# Set to 10ns (10% of period) to give plenty of room
set_input_delay -max 10.0 -clock clk [all_inputs]
set_output_delay -max 10.0 -clock clk [all_outputs]

# 3. Ideal Networks
set_ideal_network [get_ports reset]
set_ideal_network [get_ports clk]

# 4. DRC 
set_max_fanout 20 [current_design]
set_max_transition 1.0 [current_design]