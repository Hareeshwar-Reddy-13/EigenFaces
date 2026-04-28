 
set PROJECT_DIR "/mnt/hgfs/VMshare/Verilog/eigen_folder_neat"
set STD_PATH "/mnt/hgfs/VMshare/scl180/stdcell/fs120/4M1IL"
restoreDesign "$PROJECT_DIR/outputs/04_routed.dsn.dat" eigen_top

streamOut "$PROJECT_DIR/outputs/final_eigen_chip.gds" \
          -mapFile "$STD_PATH/lef/gds2.map" \
          -libName DesignLib \
          -units 1000 \
          -mode ALL

puts "Final GDSII generated in outputs folder."
