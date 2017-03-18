
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name video_decode_encode -dir "D:/workspace/video_decode_encode/planAhead_run_3" -part xc3s4000fg676-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/workspace/video_decode_encode/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/workspace/video_decode_encode} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
