`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 07/25/2016 10:43:24 AM
// Design Name: 
// Module Name: acsCom
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: sub-unit of acs, to sompare and select the smaller hamming
//              distance, get the survivor path
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ACSCOM(
    input [11:0] di_accu_dis0,      //% input current accumulative hamming
    input [11:0] di_accu_dis1,      //% distance from ACSADD unit
    output [11:0] do_accu_dis,      //% output the smaller hamming distance
    output do_sur                   //% output the survivor
    );

    //*****   function to compare the accumulation distancce    *****//
    
    function [11:0] find_min_dis;
    input [11:0] di_accu_dis0;
    input [11:0] di_accu_dis1;
    begin
        if (di_accu_dis0 < di_accu_dis1) begin
            find_min_dis = di_accu_dis0;
        end
        else begin
            find_min_dis = di_accu_dis1;
        end
    end
    endfunction

    function find_sur;                
    input [11:0] a,b;
    begin
        if (a <= b) begin
            find_sur = 0;
        end
        else begin
            find_sur = 1;        
        end    
    end
    endfunction
   
    assign do_accu_dis = find_min_dis(di_accu_dis0,di_accu_dis1);
    assign do_sur = find_sur(di_accu_dis0,di_accu_dis1);


endmodule
