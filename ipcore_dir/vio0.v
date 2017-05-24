///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.7
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : vio0.v
// /___/   /\     Timestamp  : Mon Oct 24 19:35:12 China Standard Time 2016
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module vio0(
    CONTROL,
    ASYNC_OUT) /* synthesis syn_black_box syn_noprune=1 */;


inout [35 : 0] CONTROL;
output [0 : 0] ASYNC_OUT;

endmodule
