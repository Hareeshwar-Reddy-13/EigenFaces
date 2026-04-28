set PROJECT_DIR "/mnt/hgfs/VMshare/Verilog/eigen_folder_neat"
restoreDesign "$PROJECT_DIR/outputs/03_placed.dsn.dat" eigen_top

# Special Route for Power
sroute -connect { blockPin corePin padPin } -layerChangeRange { 1 4 } -allowLayerChange 1

# Signal Routing
setNanoRouteMode -quiet -routeWithTimingDriven true
routeDesign -globalDetail

# Verification
verifyGeometry -report "$PROJECT_DIR/reports/geom.rpt"
verifyConnectivity -type all -report "$PROJECT_DIR/reports/conn.rpt"

saveDesign "$PROJECT_DIR/outputs/04_routed.dsn"
