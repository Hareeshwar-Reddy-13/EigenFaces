 
# =====================================================================
# FULLY AUTOMATED ENCOUNTER FLOW (SCL 180nm)
# Run from the 'run/' directory: encounter -nowin -init ../scripts/pnr_oneshot.tcl
# =====================================================================

# ---------------------------------------------------------------------
# 1. PROJECT VARIABLES (Change DESIGN_NAME for new projects)
# ---------------------------------------------------------------------
set DESIGN_NAME "eigen_top"

set OUT_DIR "../outputs"
set RPT_DIR "../reports"
set SDC_DIR "../sdc"

set PDK_PATH "/mnt/hgfs/VMshare/scl180"
set STD_PATH "$PDK_PATH/stdcell/fs120/4M1IL"
set MAP_FILE "$PDK_PATH/digital_pnr_kit/snps/non_rh/4M1L/icc_gds_out_4LM.map"

puts "--- STARTING AUTOMATED PHYSICAL DESIGN FOR: $DESIGN_NAME ---"

# ---------------------------------------------------------------------
# 2. DESIGN IMPORT & MMMC SETUP
# ---------------------------------------------------------------------
set init_verilog "$OUT_DIR/${DESIGN_NAME}_synth.v"
set init_top_cell $DESIGN_NAME
set init_lef_file [list "$STD_PATH/lef/scl18fs120_tech.lef" "$STD_PATH/lef/scl18fs120_std.lef"]
set init_pwr_net "VDD"
set init_gnd_net "VSS"

create_library_set -name SCL_SS -timing [list "$STD_PATH/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib"]
create_delay_corner -name SCL_CORNER -library_set SCL_SS
create_constraint_mode -name FUNC -sdc_files [list "$OUT_DIR/${DESIGN_NAME}_synth.sdc"]
create_analysis_view -name SCL_VIEW -constraint_mode FUNC -delay_corner SCL_CORNER

init_design -setup {SCL_VIEW} -hold {SCL_VIEW}

# ---------------------------------------------------------------------
# 3. FLOORPLAN & POWER GRID
# ---------------------------------------------------------------------
puts "--- RUNNING FLOORPLAN ---"
floorPlan -site CoreSite -r 1.0 0.6 20 20 20 20
addRing -nets {VDD VSS} -width 5 -spacing 2 -layer {top Metal4 bottom Metal4 left Metal3 right Metal3}
addStripe -nets {VSS VDD} -layer Metal3 -width 2.5 -spacing 1.5 -set_to_set_distance 40
sroute -connect { blockPin corePin padPin } -layerChangeRange { 1 4 } -allowLayerChange 1

# ---------------------------------------------------------------------
# 4. PLACEMENT
# ---------------------------------------------------------------------
puts "--- RUNNING PLACEMENT ---"
setPlaceMode -timingDriven true
placeDesign

# ---------------------------------------------------------------------
# 5. CLOCK TREE SYNTHESIS (Legacy Engine for License Compatibility)
# ---------------------------------------------------------------------
puts "--- RUNNING CLOCK TREE SYNTHESIS ---"
createClockTreeSpec -output ../scripts/clk.spec
specifyClockTree -file ../scripts/clk.spec
ckSynthesis -forceReconvergent -check
optDesign -postCTS

# ---------------------------------------------------------------------
# 6. ROUTING
# ---------------------------------------------------------------------
puts "--- RUNNING NANOROUTE ---"
setNanoRouteMode -quiet -routeWithTimingDriven true
routeDesign -globalDetail

# ---------------------------------------------------------------------
# 7. FILLER CELL INSERTION (MANDATORY FOR SCL 180nm)
# ---------------------------------------------------------------------
puts "--- ADDING FILLER CELLS ---"
addFiller -cell {feedth feedth3 feedth9} -prefix FILL

# ---------------------------------------------------------------------
# 8. VERIFICATION & REPORTING
# ---------------------------------------------------------------------
puts "--- GENERATING FINAL REPORTS & VERIFICATION ---"
verifyGeometry -report $RPT_DIR/final_drc.rpt
verifyConnectivity -type all -report $RPT_DIR/final_lvs.rpt
report_area > $RPT_DIR/final_area.rpt
report_power -outfile $RPT_DIR/final_power.rpt
timeDesign -postRoute -outDir $RPT_DIR/final_timing
summaryReport -outDir $RPT_DIR/final_summary

# ---------------------------------------------------------------------
# 9. GDSII STREAM OUT
# ---------------------------------------------------------------------
puts "--- EXPORTING GDSII ---"
streamOut "$OUT_DIR/${DESIGN_NAME}_final.gds" \
          -mapFile $MAP_FILE \
          -libName DesignLib \
          -units 1000 \
          -mode ALL

# Save the final Encounter database so you can open it in the GUI later to take screenshots
saveDesign "$OUT_DIR/${DESIGN_NAME}_final.dsn"

puts "=================================================================="
puts " SUCCESS! GDSII GENERATED AT: $OUT_DIR/${DESIGN_NAME}_final.gds "
puts "=================================================================="

# Optional: Exit the tool automatically when done
# exit
