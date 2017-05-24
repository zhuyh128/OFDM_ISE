//% @file stmu.v
//% @brief Implementation file of Signal Tone Map Unit(STMU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-24

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Signal Tone Map Unit(STMU) finish the tone mapping for signal segment.
//% 
//% **Timing:**
//% 
//% 1. input continous channel encoded data
//% 2. group every 2 bits into a result(tone mapping), output a result every two
//%    clock period
//% 
//% @note    Signal segment using QPSK modulation.
//% @note    Because the signal segment using one OFDM symbol exactly, so 
//%          needn't count the sub-carrier to reset scramble in later module
//% 
//% @warning This module only works under N = 512 because only use the center 
//%          480 sub-carrier.
module STMU (
    input               clk,        //% working clock
    input               rst,        //% asynchronous reset, active high
    input               di,         //% input data to be tone mapped
    input               di_vld,     //% input data valid

    output  reg  [1:0]  do,         //% tone mapped data output
    output  reg         do_vld      //% output data valid
    );

//==============================================================================
// Local Parameter Declaration

    localparam  BITS_MAX = 1;    //% bits counter max, QPSK using 2 bits

//==============================================================================
// Main Body of Code

    //--------------------------------------------------
    // tone mapping

    reg     [1:0]   bits_cnt;        //% counter used to group data
    //% counter module 2
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            bits_cnt <= 0;
        end
        else begin
            if (di_vld) begin
                if (bits_cnt == BITS_MAX) 
                    bits_cnt <= 0;
                else 
                    bits_cnt <= bits_cnt + 1;
            end
            else begin
                bits_cnt <= 0;
            end
        end
    end

    //% tone mapping
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            case (bits_cnt)
                2'd0:    do <= {di, 1'b0};     // push d0 into tmp
                2'd1:    do <= {di, do[1]};    // valid do {d1, d0}
                default: do <= 0;
            endcase
        end
    end

    //% align the do & do_vld
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            if (bits_cnt == BITS_MAX) begin
                do_vld <= 1;
            end
            else begin
                do_vld <= 0;
            end
        end
    end

endmodule