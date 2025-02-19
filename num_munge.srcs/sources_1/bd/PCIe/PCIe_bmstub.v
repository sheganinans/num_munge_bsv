// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module PCIe (
  sys_clk_clk_p,
  sys_clk_clk_n,
  sys_ddr_clk_n,
  sys_ddr_clk_p,
  DDR3_dq,
  DDR3_dqs_p,
  DDR3_dqs_n,
  DDR3_addr,
  DDR3_ba,
  DDR3_ras_n,
  DDR3_cas_n,
  DDR3_we_n,
  DDR3_reset_n,
  DDR3_ck_p,
  DDR3_ck_n,
  DDR3_cke,
  DDR3_cs_n,
  DDR3_dm,
  DDR3_odt,
  pci_exp_rxn,
  pci_exp_rxp,
  pci_exp_txn,
  pci_exp_txp,
  sys_rst_n,
  sys_rst
);

  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 sys_clk CLK_P" *)
  (* X_INTERFACE_MODE = "slave sys_clk" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, CAN_DEBUG false, FREQ_HZ 100000000" *)
  input [0:0]sys_clk_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 sys_clk CLK_N" *)
  input [0:0]sys_clk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 sys_ddr CLK_N" *)
  (* X_INTERFACE_MODE = "slave sys_ddr" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_ddr, CAN_DEBUG false, FREQ_HZ 200000000" *)
  input sys_ddr_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 sys_ddr CLK_P" *)
  input sys_ddr_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 DQ" *)
  (* X_INTERFACE_MODE = "master DDR3" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR3, CAN_DEBUG false, TIMEPERIOD_PS 1250, MEMORY_TYPE COMPONENTS, DATA_WIDTH 8, CS_ENABLED true, DATA_MASK_ENABLED true, SLOT Single, MEM_ADDR_MAP ROW_COLUMN_BANK, BURST_LENGTH 8, AXI_ARBITRATION_SCHEME TDM, CAS_LATENCY 11, CAS_WRITE_LATENCY 11" *)
  inout [31:0]DDR3_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 DQS_P" *)
  inout [3:0]DDR3_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 DQS_N" *)
  inout [3:0]DDR3_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 ADDR" *)
  output [14:0]DDR3_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 BA" *)
  output [2:0]DDR3_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 RAS_N" *)
  output DDR3_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 CAS_N" *)
  output DDR3_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 WE_N" *)
  output DDR3_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 RESET_N" *)
  output DDR3_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 CK_P" *)
  output [0:0]DDR3_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 CK_N" *)
  output [0:0]DDR3_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 CKE" *)
  output [0:0]DDR3_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 CS_N" *)
  output [0:0]DDR3_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 DM" *)
  output [3:0]DDR3_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3 ODT" *)
  output [0:0]DDR3_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_exp rxn" *)
  (* X_INTERFACE_MODE = "master pci_exp" *)
  input [1:0]pci_exp_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_exp rxp" *)
  input [1:0]pci_exp_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_exp txn" *)
  output [1:0]pci_exp_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_exp txp" *)
  output [1:0]pci_exp_txp;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RST_N RST" *)
  (* X_INTERFACE_MODE = "slave RST.SYS_RST_N" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RST_N, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input sys_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RST RST" *)
  (* X_INTERFACE_MODE = "slave RST.SYS_RST" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input sys_rst;

  // stub module has no contents

endmodule
