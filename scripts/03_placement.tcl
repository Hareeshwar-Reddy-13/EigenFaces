set PROJECT_DIR "/mnt/hgfs/VMshare/Verilog/eigen_folder_neat"
restoreDesign "$PROJECT_DIR/outputs/02_floorplanned.dsn.dat" eigen_top

# Perform timing-driven placement
setPlaceMode -timingDriven true
placeDesign

# In legacy suites, we often run "optDesign -preCTS" here
optDesign -preCTS

saveDesign "$PROJECT_DIR/outputs/03_placed.dsn"
