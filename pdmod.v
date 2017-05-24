//% @file pdmod.v
//% @brief Implementation file of Payload De-Modulation(PDMOD) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-10-30

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload De-Modulation(PDMOD) finish the de-modulation for payload segment.
//% 
//% 
//% **data flow**
//% 
//% NFU --> PCDS --> PVDS --> PLLR
module PDMOD (
    input                   clk,            //% working clock
    input                   rst,            //% reset, active high
    input   signed  [11:0]  di_re,          //% input payload data for de-modulation
    input   signed  [11:0]  di_im,          //% input payload data for de-modulation
    input                   di_vld,         //% input data valid
    input   signed  [11:0]  di_sigma2,      //% input ssquare sigma
    input                   di_sigma2_vld,  //% input square sigma valid
    output  signed  [7 :0]  do_llr,         //% output llr for decode
    output                  do_llr_vld      //% output valid
    );

//=============================================================================
// Main Body of Code

    //-------------------------------------------------------------------------
    // NFU --> PCDS
    wire  signed  [13:0]  NFUPCDS_re;
    wire  signed  [13:0]  NFUPCDS_im;
    wire                  NFUPCDS_vld;

    //-------------------------------------------------------------------------
    // PCDS --> PVDS
    wire  signed  [13:0]  PCDSPVDS_re;
    wire  signed  [13:0]  PCDSPVDS_im;
    wire                  PCDSPVDS_vld;

    //-------------------------------------------------------------------------
    // PVDS --> PLLR
    wire  signed  [13:0]  PVDSPLLR_re;
    wire  signed  [13:0]  PVDSPLLR_im;
    wire                  PVDSPLLR_vld;
    
    //--------------------------------------------------------------------------
    // instantiate sub-module

    NFU U_NFU (
        .clk(clk),
        .rst(rst),

        .di_re(di_re),
        .di_im(di_im),
        .di_vld(di_vld),

        .do_re(NFUPCDS_re),
        .do_im(NFUPCDS_im),
        .do_vld(NFUPCDS_vld)
    );

    PCDS U_PCDS (
        .clk(clk),
        .rst(rst),

        .di_re(NFUPCDS_re),
        .di_im(NFUPCDS_im),
        .di_vld(NFUPCDS_vld),

        .do_re(PCDSPVDS_re),
        .do_im(PCDSPVDS_im),
        .do_vld(PCDSPVDS_vld)
    );

    PVDS U_PVDS (
        .clk(clk),
        .rst(rst),

        .di_re(PCDSPVDS_re),
        .di_im(PCDSPVDS_im),
        .di_vld(PCDSPVDS_vld),

        .do_re(PVDSPLLR_re),
        .do_im(PVDSPLLR_im),
        .do_vld(PVDSPLLR_vld)
    );

    /**
     * PVDS output is same with c code output 'payload_descramble.txt' 
     * approximately, LLRC output is different with c code, it's okay to
     * decode LDPC data.
     */
    
    PLLR U_PLLR (
        .clk(clk),
        .rst(rst),

        .di_re(PVDSPLLR_re),
        .di_im(PVDSPLLR_im),
        .di_vld(PVDSPLLR_vld),
        .di_sigma2(di_sigma2),
        .di_sigma2_vld(di_sigma2_vld),

        .do(do_llr),
        .do_vld(do_llr_vld)
    );

endmodule