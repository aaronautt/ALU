proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir /home/aaron/school/EGR426/cpu/cpu.cache/wt [current_project]
  set_property parent.project_path /home/aaron/school/EGR426/cpu/cpu.xpr [current_project]
  set_property ip_output_repo /home/aaron/school/EGR426/cpu/cpu.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES XPM_MEMORY [current_project]
  add_files -quiet /home/aaron/school/EGR426/cpu/cpu.runs/synth_1/ALU_TOP.dcp
  add_files -quiet /home/aaron/school/EGR426/cpu/cpu.srcs/sources_1/ip/cpuram/cpuram.dcp
  set_property netlist_only true [get_files /home/aaron/school/EGR426/cpu/cpu.srcs/sources_1/ip/cpuram/cpuram.dcp]
  read_xdc -mode out_of_context -ref cpuram -cells U0 /home/aaron/school/EGR426/cpu/cpu.srcs/sources_1/ip/cpuram/cpuram_ooc.xdc
  set_property processing_order EARLY [get_files /home/aaron/school/EGR426/cpu/cpu.srcs/sources_1/ip/cpuram/cpuram_ooc.xdc]
  read_xdc /home/aaron/school/EGR426/cpu/cpu.srcs/constrs_1/new/cpu_pins.xdc
  link_design -top ALU_TOP -part xc7a35tcpg236-1
  write_hwdef -file ALU_TOP.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force ALU_TOP_opt.dcp
  report_drc -file ALU_TOP_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force ALU_TOP_placed.dcp
  report_io -file ALU_TOP_io_placed.rpt
  report_utilization -file ALU_TOP_utilization_placed.rpt -pb ALU_TOP_utilization_placed.pb
  report_control_sets -verbose -file ALU_TOP_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force ALU_TOP_routed.dcp
  report_drc -file ALU_TOP_drc_routed.rpt -pb ALU_TOP_drc_routed.pb -rpx ALU_TOP_drc_routed.rpx
  report_methodology -file ALU_TOP_methodology_drc_routed.rpt -rpx ALU_TOP_methodology_drc_routed.rpx
  report_timing_summary -warn_on_violation -max_paths 10 -file ALU_TOP_timing_summary_routed.rpt -rpx ALU_TOP_timing_summary_routed.rpx
  report_power -file ALU_TOP_power_routed.rpt -pb ALU_TOP_power_summary_routed.pb -rpx ALU_TOP_power_routed.rpx
  report_route_status -file ALU_TOP_route_status.rpt -pb ALU_TOP_route_status.pb
  report_clock_utilization -file ALU_TOP_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force ALU_TOP_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_property XPM_LIBRARIES XPM_MEMORY [current_project]
  catch { write_mem_info -force ALU_TOP.mmi }
  write_bitstream -force -no_partial_bitfile ALU_TOP.bit 
  catch { write_sysdef -hwdef ALU_TOP.hwdef -bitfile ALU_TOP.bit -meminfo ALU_TOP.mmi -file ALU_TOP.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

