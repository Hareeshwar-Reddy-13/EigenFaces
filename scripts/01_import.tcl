# --- Path Setup ---
set PROJECT_DIR {/mnt/hgfs/VMshare/Verilog/eigen_folder_neat}
set STD_PATH {/mnt/hgfs/VMshare/scl180/stdcell/fs120/4M1IL}

# --- Design Configuration ---
set init_verilog "$PROJECT_DIR/outputs/eigen_top_synth.v"
set init_top_cell "eigen_top"
set init_lef_file [list "$STD_PATH/lef/scl18fs120_tech.lef" "$STD_PATH/lef/scl18fs120_std.lef"]
set init_pwr_net "VDD"
set init_gnd_net "VSS"

# --- MMMC (Multi-Mode Multi-Corner) Setup ---
create_library_set -name SCL_SS -timing [list "$STD_PATH/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib"]
create_delay_corner -name SCL_CORNER -library_set SCL_SS
create_constraint_mode -name FUNC -sdc_files [list "$PROJECT_DIR/outputs/eigen_top_synth.sdc"]
create_analysis_view -name SCL_VIEW -constraint_mode FUNC -delay_corner SCL_CORNER

# --- Execution ---
# Removing freeDesign for the first run to avoid the error message
init_design -setup {SCL_VIEW} -hold {SCL_VIEW}

# Verify if design loaded before saving
if {[is_design_loaded]} {
    puts "Design loaded successfully!"
    saveDesign "$PROJECT_DIR/outputs/01_imported.dsn"
} else {
    puts "ERROR: Design failed to load. Check the terminal for LEF or Netlist errors."
}v
