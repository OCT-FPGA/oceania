#==============================================================================
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
#==============================================================================
set prj_root [file normalize ..]
set p4_filepath ${prj_root}/src/box_250mhz/reconic/packet_classification

if {[info exists p4_dir]} {
  set p4file [glob -directory ${p4_dir} *.p4]
} else {
  set p4file [glob -directory ${p4_filepath} *.p4]
}

puts "p4file = ${p4file}"
create_ip -name vitis_net_p4 -vendor xilinx.com -library ip -version 1.3 -module_name packet_parser -dir ${ip_build_dir}

set_property CONFIG.P4_FILE "${p4file}" [get_ips packet_parser]

set_property -dict [list CONFIG.JSON_TIMESTAMP {1653047084} CONFIG.TOTAL_LATENCY {23} CONFIG.EN_STATS_REGS {true} CONFIG.Component_Name {packet_parser}] [get_ips packet_parser]
