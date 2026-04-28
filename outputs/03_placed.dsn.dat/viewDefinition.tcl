create_library_set -name SCL_SS\
   -timing\
    [list /mnt/hgfs/VMshare/scl180/stdcell/fs120/4M1IL/liberty/lib_flow_ss/tsl18fs120_scl_ss.lib]
create_rc_corner -name default_rc_corner\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0
create_delay_corner -name SCL_CORNER\
   -library_set SCL_SS
create_constraint_mode -name FUNC\
   -sdc_files\
    [list /mnt/hgfs/VMshare/Verilog/eigen_folder_neat/outputs/eigen_top_synth.sdc]
create_analysis_view -name SCL_VIEW -constraint_mode FUNC -delay_corner SCL_CORNER
set_analysis_view -setup [list SCL_VIEW] -hold [list SCL_VIEW]
