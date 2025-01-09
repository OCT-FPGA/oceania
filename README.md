# Oceania
<u><ins>**O**<ins></u>pen <u><ins>**C**<ins></u>loud r<u><ins>**E**<ins></u>configur<u><ins>**A**<ins></u>ble <u><ins>**NI**<ins></u>c offlo<u><ins>**A**<ins></u>ding (<u>**OCEANIA**</u>) is a project that uses [AMD RecoNIC Project](https://github.com/Xilinx/RecoNIC) to bring RDMA into the OCT project for researchers. RDMA technology offloads the traditional network stack onto the underlying NIC hardware, achieving zero-copy networking and reducing CPU involvement. Following the instructions, users can build the RecoNIC project for Alveo U280 FPGA in OCT.




## Environment

If you are using a NERC build machine with the P4 tool installed. The environment has been set up for you. If you are not familiar with NERC follow these directions to create an account and setup an instance from [here](https://docs.google.com/document/d/1_JZ1K0lDdCTKP6TePhMbEBIyySO4jYZbF9-yBIQO07A/edit). If you are using your own machine, you should have the following:

* Vivado 2021.2
* vitis_net_p4 <br/>
How to enable vitis_net_p4: (1) before Vivado installation, we need to '$ export VitisNetP4_Option_VISIBLE=true'; (2) When running Vivado installer, you should be able to see the option for Vitis Networking P4. Make sure you select the vitis_net_p4 option.
* ERNIC license <br/>
ERNIC license is required in this project. You can either purchase or apply for it through [AMD University Program](https://www.xilinx.com/support/university.html). For further details, please visit [AMD ERNIC](https://www.xilinx.com/products/intellectual-property/ef-di-ernic.html) website.
* python >= 3.8
* [Xilinx Board Store](https://github.com/Xilinx/XilinxBoardStore)
  ```
  $ git clone https://github.com/Xilinx/XilinxBoardStore
  $ export BOARD_REPO=/your/path/to/XilinxBoardStore
  ```

## System Requirement

* At least two servers, each one has an AMD-Xilinx Alveo U280 FPGA board (A Cloudlab experiment should be created with two nodes. Instructions are given [here](https://github.com/OCT-FPGA/oct-tutorials/tree/master/cloudlab-setup)).
* Experiments are tested on machines with Ubuntu 20.04 and Linux kernel version 5.4.0. 


