 
# =============================================================
# STEP 04: CLOCK TREE SYNTHESIS (CTS)
# =============================================================

# 1. Load the previous placement session
set PROJECT_DIR {/mnt/hgfs/VMshare/Verilog/eigen_folder_neat}
restoreDesign "$PROJECT_DIR/outputs/03_placed.dsn.dat" eigen_top

# 2. Specify the CTS Configuration
# We use the SCL standard cell buffers for the clock tree
set_ccopt_property buffer_cells {clk_buf_1 clk_buf_2 clk_buf_4}
set_ccopt_property inverter_cells {clk_inv_1 clk_inv_2 clk_inv_4}

# 3. Set Design Constraints for CTS
# Since we have 100ns, we can afford a bit of skew, but let's keep it tight
set_ccopt_property target_skew 0.300
set_ccopt_property target_max_trans 0.500

# 4. Run Clock Tree Synthesis
# This command inserts buffers and balances the tree
create_ccopt_clock_tree_spec
ccopt_design

# 5. Post-CTS Optimization
# Clean up any timing or DRC issues caused by buffer insertion
optDesign -postCTS

# 6. Verify and Report
report_ccopt_skew_groups > "$PROJECT_DIR/reports/cts_skew.rpt"
report_ccopt_clock_trees > "$PROJECT_DIR/reports/cts_tree.rpt"
timeDesign -postCTS > "$PROJECT_DIR/reports/cts_timing.rpt"

# 7. Save the Session
saveDesign "$PROJECT_DIR/outputs/04_cts.dsn"
puts "--- CTS COMPLETED SUCCESSFULLY ---"
