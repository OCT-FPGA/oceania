# Oceania
<u><ins>**O**<ins></u>pen <u><ins>**C**<ins></u>loud r<u><ins>**E**<ins></u>configur<u><ins>**A**<ins></u>ble <u><ins>**NI**<ins></u>c offlo<u><ins>**A**<ins></u>ding (<u>**OCEANIA**</u>) is a project that uses [AMD RecoNIC Project](https://github.com/Xilinx/RecoNIC) to bring RDMA into the OCT project for researchers. RDMA technology offloads the traditional network stack onto the underlying NIC hardware, achieving zero-copy networking and reducing CPU involvement. Following the instructions, users can build the RecoNIC project for Alveo U280 FPGA in OCT.

**Note: The Oceania project currently utilizes RecoNIC with ERNIC 3.1. However, this version contains certain internal issues related to the ERNIC IP. For example, data verbs can be used individually multiple times, but switching back to RDMA Read operation from other RDMA operations will cause the RDMA core and DMA engine to go into a bad state. We are working on upgrading RecoNIC to use QDMA 5.0 and ERNIC 4.0. Stay tuned!**



## Build Machine Environment

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

## Experiment Machines Requirements

**At least two servers, each one has an AMD-Xilinx Alveo U280 FPGA board** (A Cloudlab experiment should be created with two nodes. Instructions are given [here](https://github.com/OCT-FPGA/oct-tutorials/tree/master/cloudlab-setup)).


## Build Bitstream on Build Machine

Clone the repo first:
```
git clone https://github.com/OCT-FPGA/oceania.git
```

Enter the directory and update the submodule:
```
cd oceania
git submodule update --init RecoNIC/
```

Now apply RecoNIC patches:
```
cd RecoNIC
git submodule update --init base_nics/open-nic-shell
cp -r base_nics/open-nic-shell/board_files/Xilinx/au280 $BOARD_REPO/boards/Xilinx/
cd ./scripts
./gen_base_nic.sh
```
If $BOARD_REPO is not set, please do the following
```
git clone https://github.com/Xilinx/XilinxBoardStore
export BOARD_REPO=/your/path/to/XilinxBoardStore
```

Copy build tcl script (includes launching multiple implementation tasks in Vivado) and timing constraint for AU280 to RecoNIC project, this helps meet timing requirement during placement and routing:
```
cp ../../patch/build.tcl ../base_nics/open-nic-shell/script/
cp ../../patch/timing.xdc ../base_nics/open-nic-shell/constr/au280/
```

Build the bitstream now:
```
make build_nic
```

Once the bitstream is successfully built. From the command line, do the following to enter Vivado Command Line tool:
```
vivado -mode tcl
```
In Vivado shell, convert .bit file into .mcs file. In OCT, FPGAs are programmed using PCIe:
```
write_cfgmem -format mcs -size 128 -interface SPIx4 -loadbit "up 0x01002000 open_nic_shell.bit" -file "reconic.mcs"
```
Save and copy the generated reconic.mcs file to the experiment servers in OCT(A Cloudlab experiment should be created with two nodes with two Alveo U280 FPGAs. Instructions are given [here](https://github.com/OCT-FPGA/oct-tutorials/tree/master/cloudlab-setup)).


## Program FPGAs on OCT Nodes
Once the reconic.mcs has been copied to the two reserved OCT nodes, run the following to program the two FPGAs:
```
sudo xbflash2 program --spi --image ./reconic.mcs --bar-offset 0x40000 -d 3b:00.0
```

## Get System up on OCT Nodes

Clone the repo first
```
git clone https://github.com/OCT-FPGA/oceania.git
```

Enter the directory and update the submodule
```
cd oceania
git submodule update --init RecoNIC/
cd RecoNIC
```

Install the RecoNIC driver
```
git submodule update --init drivers/onic-driver
cd ./scripts
./gen_nic_driver.sh
cd ../drivers/onic-driver
make
sudo insmod onic.ko
```

Get MAC address and ethernet interface name assigned by the driver
```
dmesg | grep "Set MAC address to"
onic 0000:d8:00.0 onic216s0f0 (uninitialized): Set MAC address to 0:a:35:29:33:0
```

In this example, the new MAC address is [0x00, 0x0a, 0x35, 0x29, 0x33, 0x00], while the ethernet interface name assigned is 'onic216s0f0'. It is possible that the ethernet interface, 'onic216s0f0', might be renamed by the operating system. You can check with the following commands.
```
dmesg | grep "renamed from"
[  146.932392] onic 0000:d8:00.0 ens8: renamed from onic216s0f0
```
In this case, the ethernet interface is renamed as "ens8" from "onic216s0f0".

Set IP addresses for the two peers

&emsp;&emsp;**Peer 1**
```
$ sudo ifconfig onic216s0f0 192.100.51.1 netmask 255.255.0.0 broadcast 192.100.255.255
```
&emsp;&emsp;**Peer 2**
```
$ sudo ifconfig onic216s0f0 192.100.52.1 netmask 255.255.0.0 broadcast 192.100.255.255
```

Test network connectivity

&emsp;&emsp;**Peer 1**
```
$ ping 192.100.52.1
PING 192.100.52.1 (192.100.52.1) 56(84) bytes of data.
64 bytes from 192.100.52.1: icmp_seq=1 ttl=64 time=0.188 ms
64 bytes from 192.100.52.1: icmp_seq=2 ttl=64 time=0.194 ms
64 bytes from 192.100.52.1: icmp_seq=3 ttl=64 time=0.222 ms
```

&emsp;&emsp;**Peer 2**
```
$ ping 192.100.51.1
PING 192.100.51.1 (192.100.51.1) 56(84) bytes of data.
64 bytes from 192.100.51.1: icmp_seq=1 ttl=64 time=0.248 ms
64 bytes from 192.100.51.1: icmp_seq=2 ttl=64 time=0.174 ms
64 bytes from 192.100.51.1: icmp_seq=3 ttl=64 time=0.201 ms
```

If everything works fine, it should return similar output from your terminals. After verifying, you can stop *ping*. The system is now up.

## Build RecoNIC user-space library
RecoNIC user-space library (green boxes shown in the above RecoNIC system overview figure) contains all necessary APIs for RDMA, memory and control operations. To obtain the document for source codes, you can simply run with
```
cd ./lib
doxygen
```
The source code documents will be generated at ./lib/html.

Before we run test cases and applications, we need to build the libreconic library.
```
make
export LD_LIBRARY_PATH=/your/path/to/RecoNIC/lib:$LD_LIBRARY_PATH
```
The generated static, *libreconic.a*, and shared library, *libreconic.so*, are located at ./lib folder. We are ready to play test cases and applications.

Currently, RecoNIC uses HugePages for memory allocation. We need to configure the number of huge pages first (Each hugepage by default is 2MB, 2048 hugepages is 4 GB of memory):
```
sudo su -
echo 2048 > /proc/sys/vm/nr_hugepages
```

## Run RDMA Test Cases
The *rdma_test* folder contains RDMA read, write and send/receive test cases using libreconic.

Build RDMA read, write and send/recv program.
```
cd examples/rdma_test
make
```

### RDMA Read
RDMA Read operation: The client node issues RDMA read request to the server node first. The server node then replies with the RDMA read response packet.
```
$ ./read -h
  usage: ./read [OPTIONS]

    -d (--device) character device name (defaults to /dev/reconic-mm)
    -p (--pcie_resource) PCIe resource
    -r (--src_ip) Source IP address
    -i (--dst_ip) Destination IP address
    -u (--udp_sport) UDP source port
    -t (--tcp_sport) TCP source port
    -q (--dst_qp) Destination QP number
    -z (--payload_size) Payload size in bytes
    -l (--qp_location) QP/mem-registered buffers' location: [host_mem | dev_mem]
    -s (--server) Server node
    -c (--client) Client node
    -g (--debug) Debug mode
    -h (--help) print usage help and exit 
```

#### On the client node (192.100.51.1)
Run the program
```
sudo ./read -r 192.100.51.1 -i 192.100.52.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 128 -l host_mem -d /dev/reconic-mm -c -u 22222 -t 11111 --dst_qp 2 -g 2>&1 | tee client_debug.log
```

#### On the server node (192.100.52.1)
Run the program
```
sudo ./read -r 192.100.52.1 -i 192.100.51.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 128 -l host_mem -d /dev/reconic-mm -s -u 22222 -t 11111 --dst_qp 2 -g 2>&1 | tee server_debug.log
```

If the program exits with an error saying libreconic.so is not found, you can try with "sudo env LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./read", instead of "sudo ./read".

The above example allocates the QP (SQ, CQ and RQ) in the host memory. If you want the QP to be allocated in the host memory, you can simply replace "-l host_mem" with "-l dev_mem" on both receiver and sender nodes.

### RDMA Write
RDMA Write operation: The client node issues RDMA write request to the server node directly. Usage of the RDMA write program is the same with RDMA read program above.

#### On the client node (192.100.51.1)
Run the program
```
sudo ./write -r 192.100.51.1 -i 192.100.52.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 128 -l host_mem -d /dev/reconic-mm -c -u 22222 -t 11111 --dst_qp 2 -g 2>&1 | tee client_debug.log
```

#### On the server node (192.100.52.1)
Run the program
```
sudo ./write -r 192.100.52.1 -i 192.100.51.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 128 -l host_mem -d /dev/reconic-mm -s -u 22222 -t 11111 --dst_qp 2 -g 2>&1 | tee server_debug.log
```

If the program exits with an error saying libreconic.so is not found, you can try with "sudo env LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./write", instead of "sudo ./write".

The above example allocates the QP (SQ, CQ and RQ) in the host memory. You can allocate QPs on device memory as well by using "-l dev_mem" on both receiver and sender nodes.

### RDMA Send/Receive
RDMA send/recv operation: The server node posts an RDMA receive request, waiting for a RDMA send request to its allocated receive queue. The client node then issues an RDMA send request to the server node. Usage of the RDMA send/receive program is the same iwth RDMA read program above.

#### On the receiver node (192.100.51.1)
Run the program in the receiver mode
```
sudo ./send_recv -r 192.100.51.1 -i 192.100.52.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 128 -l host_mem -d /dev/reconic-mm -c -u 22222 --dst_qp 2 -g 2>&1 | tee client_debug.log
```

#### On the sender node (192.100.52.1)
Run the program in the sender mode
```
sudo ./send_recv -r 192.100.52.1 -i 192.100.51.1 -p /sys/bus/pci/devices/0000\:d8\:00.0/resource2 -z 16384 -l dev_mem -d /dev/reconic-mm -s -u 22222 --dst_qp 2 -g 2>&1 | tee server_debug.log
```

If the program exits with an error saying libreconic.so is not found, you can try with "sudo env LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./send_recv", instead of "sudo ./send_recv".

The above example allocates the QP (SQ, CQ and RQ) in the host memory. You can allocate QPs on device memory as well by using "-l dev_mem" on both receiver and sender nodes.


## Reference
RecoNIC Repository: https://github.com/Xilinx/RecoNIC

Getting Started with FPGAs in OCT: https://github.com/OCT-FPGA/oct-tutorials/tree/master/cloudlab-setup
