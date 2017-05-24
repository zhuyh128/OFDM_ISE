//% @file pcdm.v
//% @brief Implementation file of Payload Constellation De-Modulation(PCDM) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-10-05

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload Constellation De-Mapping(PCDM) finish the constellation de-modulation 
//% for payload segment, calculate the LLR.
//%
//% @note only support 16QAM
//% @note using input and output buffer to solve data rate change
module PCDM (
    input                  clk,
    input                  rst,
    input  signed  [13:0]  di_re,
    input  signed  [13:0]  di_im,
    input                  di_vld,
    output reg signed      do,
    output                 do_vld
    );

//=============================================================================
// Main Body of code

    //-------------------------------------------------------------------------
    // using a FIFO save the input data

    wire  inbuf_full;
    reg   inbuf_wr_en;

    wire  inbuf_empty;
    reg   inbuf_rd_en;

    reg  signed  [13:0]  inbuf_do_re;
    reg  signed  [13:0]  inbuf_do_im;


    PCDM_INBUF_RE U_PCDM_INBUF_RE (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(inbuf_di_re),      // input wire [13 : 0] din
        .wr_en(inbuf_wr_en_re),  // input wire wr_en
        .rd_en(inbuf_rd_en_re),  // input wire rd_en
        .dout(inbuf_do_re),    // output wire [13 : 0] dout
        .full(inbuf_full_re),    // output wire full
        .empty(inbuf_empty_re),  // output wire empty
        .valid(inbuf_valid_re)  // output wire valid
    );

    PCDM_INBUF_IM your_instance_name (
        .clk(clk),      // input wire clk
        .srst(srst),    // input wire srst
        .din(inbuf_di_im),      // input wire [13 : 0] din
        .wr_en(inbuf_wr_en),  // input wire wr_en
        .rd_en(inbuf_rd_en),  // input wire rd_en
        .dout(inbuf_do_im),    // output wire [13 : 0] dout
        .full(inbuf_full),    // output wire full
        .empty(inbuf_empty),  // output wire empty
        .valid(inbuf_valid_im)  // output wire valid
    );



endmodule