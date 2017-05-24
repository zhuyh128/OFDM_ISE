//% @file pllr.v
//% @brief Implementation file of Payload LLR(PLLR) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-16

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload LLR (PLLR) finish the calculation of llr for payload.
//% 
//& PLLR
//%  |
//%  |-- PNC ----------->|
//%  |                   | --> LLRC
//%  |-- PFC --> PCMI -->|
module PLLR (
    input                        clk,               //% working clock
    input                        rst,               //% reset, active high
    input        signed  [13:0]  di_re,             //% input payload data real part
    input        signed  [13:0]  di_im,             //% input payload data image part
    input                        di_vld,            //% input data valid
    input        signed  [11:0]  di_sigma2,         //% input square sigma 
    input                        di_sigma2_vld,     //% input saqure sigma valid
    output       signed  [7 :0]  do,                //% output llr
    output                       do_vld             //% output llr valid
    );

//=============================================================================
// Main Body of Code

    //-------------------------------------------------------------------------
    // PNC --> LLRC
    wire  signed  [11:0]  PNCLLRC_data;
    wire                  PNCLLRC_data_vld;

    //-------------------------------------------------------------------------
    // PFU --> PCMI
    wire  signed  [14:0]  PFCPCMI_re;
    wire  signed  [14:0]  PFCPCMI_im;
    wire                  PFCPCMI_vld;

    //-------------------------------------------------------------------------
    // PCMI --> LLRC
    wire  signed  [14:0]  PCMILLRC_mi;
    wire                  PCMILLRC_mi_vld;

    //--------------------------------------------------------------------------
    // instantiate sub-module

    // branch 1
    PNC U_PNC (
        .clk(clk),
        .rst(rst),
        
        .di(di_sigma2),
        .di_vld(di_sigma2_vld),

        .do(PNCLLRC_data),
        .do_vld(PNCLLRC_data_vld)
    );

    // branch 2
    PFC U_PFC (
        .clk(clk),
        .rst(rst),
        
        .di_re(di_re),
        .di_im(di_im),
        .di_vld(di_vld),

        .do_re(PFCPCMI_re),
        .do_im(PFCPCMI_im),
        .do_vld(PFCPCMI_vld)
    );

    PCMI U_PCMI (
        .clk(clk),
        .rst(rst),

        .di_re(PFCPCMI_re),
        .di_im(PFCPCMI_im),
        .di_vld(PFCPCMI_vld),
        
        .do(PCMILLRC_mi),
        .do_vld(PCMILLRC_mi_vld)
    );

    // final llr

    LLRC U_LLRC (
        .clk(clk),
        .rst(rst),

        .di_kf(PNCLLRC_data),
        .di_kf_vld(PNCLLRC_data_vld),
        .di_mi(PCMILLRC_mi),
        .di_mi_vld(PCMILLRC_mi_vld),

        .do(do),
        .do_vld(do_vld)
    );
    
endmodule