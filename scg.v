//% @file scg.v
//% @brief Implementation file of System Clock Generation(SCG) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-11

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% System Clock Generation (SCG) module generate all the clock for both of 
//% transmitter and receiver.
//% 
//% using a Clock IP core
module SCG (
    input   clk_i,
    input   rst_i,          // active high
    output  clk_trans_sig,
    output  clk_trans_pld,
    output  clk_recv,
    output  locked
    );

//==============================================================================
// Main Body of Code

    wire  clk_out50MHz;          // 10MHz
    wire  clk_out150MHz_1;       // 30MHz
    wire  clk_out150MHz_2;       // 30MHz
    wire  locked0;

    // SCG_clock U_SCG_clock (
    //    // Clock in ports
    //     .clk_in100MHz(clk_i),      // input clk_in100MHz
    //     // Clock out ports
    //     .clk_out50MHz(clk_out50MHz),     // output clk_out50MHz
    //     .clk_out150MHz_1(clk_out150MHz_1),     // output clk_out150MHz
    //     .clk_out150MHz_2(clk_out150MHz_2),     // output clk_out150MHz
    //     // Status and control signals
    //     .RESET(rst_i), // input reset
    //     .LOCKED(locked0)
    // );      // output locked
    
    assign clk_trans_sig = locked ? clk_out50MHz    : 0;
    assign clk_trans_pld = locked ? clk_out150MHz_1 : 0;
    assign clk_recv      = locked ? clk_out150MHz_2 : 0;
    assign locked = locked0;

endmodule