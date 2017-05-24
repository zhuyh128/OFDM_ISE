`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 09/08/2016 05:28:57 PM
// Design Name: 
// Module Name: SCD
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: Signal Channel Decoder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
//
//% Signal Channel Decoder(SCD) finish the convolution decode of received signal 
//% data(96) 
//%
//% GRC --> (INRAM) --> CBD --> ACS --> TBU 

module SCD(
    input       clk,        //% working clock
    input       rst,        //% reset, active high
    input       di,         //% input signal data after de-modulation
    input       di_vld,     //% input data valid
    output      do,         //% output decoded signal data
    output      do_vld      //% output data valid
    );
    
// =========================================================================
// Main Body of Code
    
    // -----------------------------------------------------------------------
    // GRC -> INRAM
    wire [2:0] GRC2INRAM;
    wire GRC2INRAM_vld;

    // -----------------------------------------------------------------------
    // INRAM -> CBD
    wire [2:0] INRAM2CBD;
    wire INRAM2CBD_vld;

    // -----------------------------------------------------------------------
    // CBD -> ACS
    wire [1:0] CBD2ACS0;
    wire [1:0] CBD2ACS1;
    wire [1:0] CBD2ACS2;
    wire [1:0] CBD2ACS3;
    wire [1:0] CBD2ACS4;
    wire [1:0] CBD2ACS5;
    wire [1:0] CBD2ACS6;
    wire [1:0] CBD2ACS7;
    wire CBD2ACS_vld;

    // -----------------------------------------------------------------------
    // ACS -> TBU 
    wire [63:0] ACS2TBU_sur;
    wire ACS2TBU_sur_vld;
    wire [5:0] ACS2TBU_state;
    wire ACS2TBU_state_vld;

    // -----------------------------------------------------------------------
    // instantiate the sub-module

    GRC U_GRC(
        .clk(clk),
        .rst(rst),
        .di(di),
        .di_vld(di_vld),
        .do(GRC2INRAM),
        .do_vld(GRC2INRAM_vld)
        );

    INRAM U_INRAM(
        .clk(clk),
        .rst(rst),
        .di(GRC2INRAM),
        .di_vld(GRC2INRAM_vld),
        .do(INRAM2CBD),
        .do_vld(INRAM2CBD_vld)
        );

    CBD U_CBD(
        .clk(clk),
        .rst(rst),
        .di(INRAM2CBD),
        .di_vld(INRAM2CBD_vld),
        .do_0(CBD2ACS0),
        .do_1(CBD2ACS1),
        .do_2(CBD2ACS2),
        .do_3(CBD2ACS3),
        .do_4(CBD2ACS4),
        .do_5(CBD2ACS5),
        .do_6(CBD2ACS6),
        .do_7(CBD2ACS7),
        .do_vld(CBD2ACS_vld)
        );

    ACS U_ACS(
        .clk(clk),
        .rst(rst),
        .di0(CBD2ACS0),
        .di1(CBD2ACS1),
        .di2(CBD2ACS2),
        .di3(CBD2ACS3),
        .di4(CBD2ACS4),
        .di5(CBD2ACS5),
        .di6(CBD2ACS6),
        .di7(CBD2ACS7),
        .di_vld(CBD2ACS_vld),
        .do_sur(ACS2TBU_sur),
        .do_sur_vld(ACS2TBU_sur_vld),
        .do_smallest_state(ACS2TBU_state),
        .do_smallest_vld(ACS2TBU_state_vld)
        );

    TBU U_TBU(
        .clk(clk),
        .rst(rst),
        .di_sur_path(ACS2TBU_sur),
        .di_sur_path_vld(ACS2TBU_sur_vld),
        .di_cur_state(ACS2TBU_state),
        .di_cur_state_vld(ACS2TBU_state_vld),
        .do_sur(do),
        .do_vld(do_vld)
        );

endmodule
