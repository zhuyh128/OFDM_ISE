`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 07/25/2016 11:04:49 AM
// Design Name: 
// Module Name: acs
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implementation file of add compare & select unit 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SUB_ACS(
    input [1:0] di_branch_dis0,        // input possible hamming distance
    input [1:0] di_branch_dis1,
    input [11:0] di_accu_dis0,          // input previous accumulative distance
    input [11:0] di_accu_dis1,
    output [11:0] do_accu_dis,      // output the selected new accumulative distance
    output do_sur                  // output the survivor
    );

    // ACSADD -> ACSCOM
    wire [11:0] ADDCOM_dis0;          // output of acsadd unit, two possible
    wire [11:0] ADDCOM_dis1;          // current accumulative distance
    // wire ADDCOM_vld;

    ACSADD U_ACSADD(
        .di_branch_dis0(di_branch_dis0),
        .di_branch_dis1(di_branch_dis1),
        .di_accu_dis0(di_accu_dis0),
        .di_accu_dis1(di_accu_dis1),
        .do_accu_dis0(ADDCOM_dis0),
        .do_accu_dis1(ADDCOM_dis1)
        );

    ACSCOM U_ACSCOM(
        .di_accu_dis0(ADDCOM_dis0),
        .di_accu_dis1(ADDCOM_dis1),
        .do_accu_dis(do_accu_dis),
        .do_sur(do_sur)
        );
    
endmodule
