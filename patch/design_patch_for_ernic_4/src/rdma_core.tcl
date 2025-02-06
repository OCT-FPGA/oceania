# *************************************************************************
#
# Copyright 2022 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************
set rdma rdma_core
create_ip -name ernic -vendor xilinx.com -library ip -version 4.0 -module_name $rdma -dir ${ip_build_dir}

set_property -dict {
    CONFIG.C_NUM_QP {32}
    CONFIG.C_S_AXI_LITE_ADDR_WIDTH {32}
    CONFIG.C_M_AXI_ADDR_WIDTH {64}
    CONFIG.C_EN_DEBUG_PORTS {1}
    CONFIG.C_MAX_WR_RETRY_DATA_BUF_DEPTH {2048}
    CONFIG.C_EN_INITIATOR_LITE {1}
} [get_ips $rdma]
