`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 07/25/2016 10:32:32 AM
// Design Name: 
// Module Name: acsadd
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: sub-unit of acs,to compute the accusmulative distance
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ACSADD(
    input [1:0] di_branch_dis0,        //% input branch hamming distance
    input [1:0] di_branch_dis1,        //% from CBD unit
    input [11:0] di_accu_dis0,         //% input previous accumulative hamming distance
    input [11:0] di_accu_dis1,
    output [11:0] do_accu_dis0,        //% output current accumulative hamming distance
    output [11:0] do_accu_dis1         //% for ACSCOM unit to select
    );

    assign do_accu_dis0 = di_accu_dis0 + {9'b0,di_branch_dis0};
    assign do_accu_dis1 = di_accu_dis1 + {9'b0,di_branch_dis1};
    

endmodule
