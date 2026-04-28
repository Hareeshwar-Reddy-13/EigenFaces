set PROJECT_DIR "/mnt/hgfs/VMshare/Verilog/eigen_folder_neat"
restoreDesign "${PROJECT_DIR}/outputs/01_imported.dsn.dat" eigen_top

# Utilization for SCL 180nm
floorPlan -site CoreSite -r 1.0 0.6 20 20 20 20
addRing -nets {VDD VSS} -width 5 -spacing 2 -layer {top Metal4 bottom Metal4 left Metal3 right Metal3}
addStripe -nets {VSS VDD} -layer Metal3 -width 2.5 -spacing 1.5 -set_to_set_distance 40

saveDesign "${PROJECT_DIR}/outputs/02_floorplanned.dsn"
