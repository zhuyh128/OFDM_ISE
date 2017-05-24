//% @file sdmod.v
//% @brief Implementation file of Signal De-Modulation(SDMOD) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-30

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

// Signal De-Modulation(SDMOD) finish the de-modulation for signal segment.
module SDMOD (
    input                  clk,         //% working clock
    input                  rst,         //% reset, active high
    input  signed  [11:0]  di_re,       //% input signal data
    input  signed  [11:0]  di_im,       //% input signal data
    input                  di_vld,      //% input data valid
    output                 do,          //% output signal data to be decoded
    output                 do_vld       //% output data valid
    );

//=============================================================================
// Main Body of Code

    //-------------------------------------------------------------------------
    // SCDS --> SCMD
    wire  signed  [11:0]  SCDS2SCDM_re;
    wire  signed  [11:0]  SCDS2SCDM_im;
    wire                  SCDS2SCDM_vld;

    //-------------------------------------------------------------------------
    // instantiate sub-module
    
    SCDS U_SCDS (
        .clk(clk),
        .rst(rst),
        .di_re(di_re),
        .di_im(di_im),
        .di_vld(di_vld),

        .do_re(SCDS2SCDM_re),
        .do_im(SCDS2SCDM_im),
        .do_vld(SCDS2SCDM_vld)
    );

    SCDM U_SCDM (
        .clk(clk),
        .rst(rst),
        .di_re(SCDS2SCDM_re),
        .di_im(SCDS2SCDM_im),
        .di_vld(SCDS2SCDM_vld),

        .do(do),
        .do_vld(do_vld)
    );

endmodule