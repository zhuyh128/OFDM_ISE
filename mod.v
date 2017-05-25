//% @file mod.v
//% @brief Implementation file of Modulation Unit(MOD) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-20

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Modulation Unit(MOD) finish the modulation(tone mapping + constellation mapping
//% + constellation scramble) for signale & payload segment.
//% 
//% **Timing**
//% 
//% 0. the input {signal, paylaod} is continous
//% 
//% 1. for signal, output one valid data every 2 clock period
//% 
//%     latency = 2(tone mapping) + 1(constellation mapping) + 1(scrambel)
//%            = 4 clock period; 
//% 
//% 2. for payload, output one valid data every 4 clock period
//% 
//%     latency = 4(tone mapping) + 1(constellation mapping) + 1(scramble)
//%             = 6 clock period;
//% 
//% @note there are 2 clock domain, one for signal and the other for payload.
module MOD (
    // signal
    input                   signal_clk,         //% working clock
    input                   signal_rst,         //% reset active high
    input                   signal_di,          //% input signal data
    input                   signal_di_vld,      //% input signal data valid

    output  signed  [11:0]  signal_do_re,       //% output signal data_re
    output  signed  [11:0]  signal_do_im,       //% output signal data_im
    output                  signal_do_vld,      //% output signal data valid

    // payload
    input                   payload_clk,        //% working clock
    input                   payload_rst,        //% reset active
    input                   payload_di,         //% input payload data
    input                   payload_di_vld,     //% input payload data valid

    output  signed  [11:0]  payload_do_re,      //% output payload data_re
    output  signed  [11:0]  payload_do_im,      //% output payload data_im
    output                  payload_do_sym_end, //% end flag of each OFDM symbol
    output                  payload_do_vld      //%output payload data valid
    );

//==============================================================================
// Wire & Reg
    wire          tmu_done_flag;        //Modified by baiyf
    wire          cmu_done_flag;
    wire          csu_done_flag;
    reg           tmu_done_rst;
    reg           cmu_done_rst;
    reg           csu_done_rst;
   
	 
    //--------------------------------------------------------------------------
    // TMU --> CMU
    wire  [1:0]  TMUCMU_signal_dat;
    wire         TMUCMU_signal_dat_vld;

    wire  [3:0]  TMUCMU_payload_dat;
    wire         TMUCMU_payload_dat_sym_end;
    wire         TMUCMU_payload_dat_vld;

    //--------------------------------------------------------------------------
    // CMU --> CSU
    wire  signed  [11:0]  CMUCSU_signal_dat_re;
    wire  signed  [11:0]  CMUCSU_signal_dat_im;
    wire                  CMUCSU_signal_dat_vld;

    wire  signed  [11:0]  CMUCSU_payload_dat_re;
    wire  signed  [11:0]  CMUCSU_payload_dat_im;
    wire                  CMUCSU_payload_dat_sym_end;
    wire                  CMUCSU_payload_dat_vld;

//==============================================================================
// Main Body of Code
    //% instantiate TMU module
    TMU U_TMU (
        // input
		  .done_rst(tmu_done_rst),
        .stmu_clk(signal_clk),   
        .stmu_rst(signal_rst),   
        .stmu_di(signal_di),    
        .stmu_di_vld(signal_di_vld),
        // ouptut
        .stmu_do(TMUCMU_signal_dat),    
        .stmu_do_vld(TMUCMU_signal_dat_vld),

        // input
        .ptmu_clk(payload_clk),       
        .ptmu_rst(payload_rst),       
        .ptmu_di(payload_di),        
        .ptmu_di_vld(payload_di_vld),    
        // output
        .ptmu_do(TMUCMU_payload_dat),        
        .ptmu_do_sym_end(TMUCMU_payload_dat_sym_end),
        .ptmu_do_vld(TMUCMU_payload_dat_vld)     
    );

    //% instantiate CMU module
    CMU U_CMU (
        // input        
		  .done_rst(cmu_done_rst),
        .signal_clk(signal_clk),        
        .signal_rst(signal_rst),               
        .signal_di(TMUCMU_signal_dat),         
        .signal_di_vld(TMUCMU_signal_dat_vld),     
        // output
        .signal_do_re(CMUCSU_signal_dat_re),      
        .signal_do_im(CMUCSU_signal_dat_im),      
        .signal_do_vld(CMUCSU_signal_dat_vld), 

        // input
        .payload_clk(payload_clk),  
        .payload_rst(payload_rst),     
        .payload_di(TMUCMU_payload_dat),        
        .payload_di_sym_end(TMUCMU_payload_dat_sym_end),
        .payload_di_vld(TMUCMU_payload_dat_vld),    
        // output
        .payload_do_re(CMUCSU_payload_dat_re),     
        .payload_do_im(CMUCSU_payload_dat_im),     
        .payload_do_sym_end(CMUCSU_payload_dat_sym_end),
        .payload_do_vld(CMUCSU_payload_dat_vld)
    );

    //% instantiate CSU module
    CSU U_CSU (
        // input
		  .done_rst(),
        .signal_clk(signal_clk),
        .signal_rst(signal_rst),
        .signal_di_re(CMUCSU_signal_dat_re),
        .signal_di_im(CMUCSU_signal_dat_im),
        .signal_di_vld(CMUCSU_signal_dat_vld),
        // output
        .signal_do_re(signal_do_re),
        .signal_do_im(signal_do_im),
        .signal_do_vld(signal_do_vld),

        // input
        .payload_clk(payload_clk),
        .payload_rst(payload_rst),
        .payload_di_re(CMUCSU_payload_dat_re),
        .payload_di_im(CMUCSU_payload_dat_im),
        .payload_di_sym_end(CMUCSU_payload_dat_sym_end),
        .payload_di_vld(CMUCSU_payload_dat_vld),
        // output
        .payload_do_re(payload_do_re),
        .payload_do_im(payload_do_im),
        .payload_do_sym_end(payload_do_sym_end), 
        .payload_do_vld(payload_do_vld)
    );

endmodule

