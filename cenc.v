//% @file cenc.v
//% @brief Implementation file of Channel Encoder(CENC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-019

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Channle Encoder(CENC) module instantiate SCE & PCE submodule to finish the 
//% channel encode for signal & payload bits.
//% 
module CENC (
    // encode signal
    input               sce_clk_i,      //% clock for input data
    input               sce_clk_o,      //% clock for output data
    input               sce_rst,        //% asynchronous reset, active high
    input               sce_di,         //% signal data input to be encoded
    input    [5 : 0]    sce_di_init,    //% data input, initialize the LSR
    input               sce_di_vld,     //% data input valid

    output              sce_do,         //% channel encoded signal data output
    output              sce_do_vld,     //% data output valid

    // encode payload bits
    input               pld_clk,
    input               pld_rst,
    input               pld_di,
    input               pld_di_vld,

    output              pld_do,
    output              pld_do_vld,
    output    [3:0]     pld_do_sym_num

    // // using FPCE module for test!
    // input               pld_clk,
    // input               pld_rst,
    // input               pld_rd_en,
    // output              pld_do,
    // output              pld_do_vld,
    // output    [3:0]     pld_do_sym_num
    );

//==============================================================================
// Main Body of Code

    //---------------------------------------------------------
    // // FPCE --> PPU
    // wire  FPCEPPU_data;
    // wire  FPCEPPU_data_vld;
    
    // PCE --> PPU
    wire PCEPPU_data;
    wire PCEPPU_data_vld;
    

    wire ppu_done_flag;                     //Modified by baiyf
    reg  sce_done_rst;
    reg  pce_done_rst;
    reg  ppu_done_rst;
    
    
    SCE U_SCE (
        .done_rst(sce_done_rst),
        .clk_i(sce_clk_i),      //% clock for input data
        .clk_o(sce_clk_o),      //% clock for output data
        .rst(sce_rst),          //% asynchronous reset, active high
        .di(sce_di),            //% signal data input to be encoded
        .di_init(sce_di_init),  //% data input, initialize the LSR
        .di_vld(sce_di_vld),    //% data input valid
        .do(sce_do),            //% channel encoded signal data output
        .do_vld(sce_do_vld)     //% data output valid
    );

    PCE U_PCE(
        .done_rst(pce_done_rst),
        .clk(pld_clk),
        .rst(pld_rst),
        .din(pld_di),
        .din_valid(pld_di_vld),
        .data_valid(PCEPPU_data_vld),
        .encode_out(PCEPPU_data),
        .encode_busy()
        );


    // FPCE U_FPCE (
    //     .clk(pld_clk), 
    //     .rst(pld_rst),
    //     .rd_en(pld_rd_en),
    //     .do(FPCEPPU_data),
    //     .do_vld(FPCEPPU_data_vld)
    // );

    PPU U_PPU (
        .done_rst(ppu_done_rst),
        .clk(pld_clk),
        .rst(pld_rst),
        .di(PCEPPU_data),
        .di_vld(PCEPPU_data_vld),
        .do(pld_do),
        .do_vld(pld_do_vld),
        .do_sym_num(pld_do_sym_num),
        .done_flag(ppu_done_flag)
    );

    always @(posedge pld_clk) begin             // ±÷”—°‘Ò?
        if(ppu_done_flag) begin
            sce_done_rst <= 1;
            pce_done_rst <= 1;
            ppu_done_rst <= 1;
        end 
        else begin
            sce_done_rst <= 0;
            pce_done_rst <= 0;
            ppu_done_rst <= 0;
        end
    end

endmodule
