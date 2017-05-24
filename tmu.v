//% @file tmu.v
//% @brief Implementation file of Tone Map Unit(TMU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-24

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Tone Map Unit(TMU) finish the tone mapping for signal & preamble segment.
//% 
//% **inlcuding 2 sub module:**
//% 
//% 1. STMU
//% 2. PTMU
module TMU (
    // STMU prots
    input          stmu_clk,        //% working clock
    input          stmu_rst,        //% asynchronous reset, active high
    input          stmu_di,         //% input signal data to be tone mapped
    input          stmu_di_vld,     //% input data valid

    output  [1:0]  stmu_do,         //% tone mapped data output
    output         stmu_do_vld,     //% output data valid

    // PTMU ports
    input          ptmu_clk,         //% working clock
    input          ptmu_rst,         //% asynchronous reset
    input          ptmu_di,          //% (channel encoded) data input to be tone mapped
    input          ptmu_di_vld,      //% input data valid

    output  [3:0]  ptmu_do,          //% output tone mapped data
    output         ptmu_do_sym_end,  //% end flag of each OFDM symbol
    output         ptmu_do_vld       //% output data valid
    );

//==============================================================================
// Main Body of Code

    //-------------------------------------------------
    //% instantiate STMU sub-module
    STMU U_STMU (
          .do(stmu_do),
          .do_vld(stmu_do_vld),
          .clk(stmu_clk),
          .rst(stmu_rst),
          .di(stmu_di),
          .di_vld(stmu_di_vld)
    );

    //-------------------------------------------------
    //% instantiate PTMU sub-module
    PTMU U_PTMU (
          .do(ptmu_do),
          .do_sym_end(ptmu_do_sym_end),
          .do_vld(ptmu_do_vld),
          .clk(ptmu_clk),
          .rst(ptmu_rst),
          .di(ptmu_di),
          .di_vld(ptmu_di_vld)
    );

endmodule