# ==============================================================
# UNIVERSAL SYNTHESIS SCRIPT (Run from 'run' directory)
# ==============================================================

# 1. CHANGE THESE TWO VARIABLES FOR NEW PROJECTS
set DESIGN_NAME "eigen_top"
set CLOCK_PERIOD 10000 ;# In picoseconds (10000ps = 10ns)

# 2. Universal Paths (Relative to 'run' folder)
set RTL_DIR "../rtl"
set OUT_DIR "../outputs"
set RPT_DIR "../reports"
set SDC_DIR "../sdc"
set PDK_PATH "/mnt/hgfs/VMshare/scl180/stdcell/fs120/4M1IL"

# 3. Setup Library
set_attribute lib_search_path $PDK_PATH/liberty/lib_flow_ss/
set_attribute library tsl18fs120_scl_ss.lib

# 4. Load & Elaborate
read_hdl -v2001 [glob $RTL_DIR/*.v]
elaborate $DESIGN_NAME

# 5. Constraints (Either load an SDC or apply basic ones)
if {[file exists $SDC_DIR/constraints.sdc]} {
    read_sdc $SDC_DIR/constraints.sdc
} else {
    puts "No SDC found. Applying default generic clock..."
    define_clock -period $CLOCK_PERIOD -name clk [find / -port clk]
}

# 6. Synthesize
synthesize -to_mapped -effort medium

# 7. Export Outputs & Reports
write_hdl > $OUT_DIR/${DESIGN_NAME}_synth.v
write_sdc > $OUT_DIR/${DESIGN_NAME}_synth.sdc

report area > $RPT_DIR/synth_area.rpt
report timing > $RPT_DIR/synth_timing.rpt
report power > $RPT_DIR/synth_power.rpt

puts "--- SYNTHESIS COMPLETE. CHECK ../outputs FOLDER ---"
