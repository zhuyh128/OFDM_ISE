//% @file nfu.v
//% @brief Implementation file of Normal Factor Unit(NFU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-09

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Normal Factor Unit(NFU) finish the unnormal for different modulation type.
//% 
//% float normal factor = {1.000000, 1.414214, 2.449490, 3.162278, 4.472136, 6.480741, 
//%                    9.055385, 13.038405, 18.165902, 26.115130, 36.359318, 52.249402};
//%                    
//% fix normal factor = float_factor * 1578
//%                   = {1578, 1578, 3865, 4990, ...}
//% 
//% @note for 16QAM, factor = 4990, "output = input*4990/1578" in c code
//        in verilog, use 3.162278 in 2Q10 format
//        3.162278 = 011.00_1010_0111 = 3238
module NFU(
    input                        clk,       //% working clock
    input                        rst,       //% reset, active high
    input        signed  [11:0]  di_re,     //% input payload data real part
    input        signed  [11:0]  di_im,     //% input payload data image part
    input        signed          di_vld,    //% input data valid
    output  reg  signed  [13:0]  do_re,     //% output data real part
    output  reg  signed  [13:0]  do_im,     //% output data image part
    output  reg                  do_vld     //% output data valid
    );

//==============================================================================
// Main Body of Code

    reg  signed  [11:0]  A_re;
    reg  signed  [11:0]  A_im;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            A_re <= 0;
            A_im <= 0;
        end
        else begin
            A_re <= di_re;
            A_im <= di_im;
        end
    end

    //--------------------------------------------------------------------------
    // get output

    wire  signed  [23:0]  P_re;
    wire  signed  [23:0]  P_im;

    // get mult result, ignore fractional part
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= P_re[23:10];   // factor is 2Q10 format
            do_im <= P_im[23:10];
        end
    end

    reg  do_vld_pre1;
    reg  do_vld_pre2;
    reg  do_vld_pre3;

    // input --> mult core 1 clock delay +  mult has 2 clock delay
    // = 3 clock delay
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld_pre1 <= 0;
            do_vld_pre2 <= 0;
            do_vld_pre3 <= 0;
            do_vld      <= 0;
        end
        else begin
            do_vld_pre1 <= di_vld;
            do_vld_pre2 <= do_vld_pre1;
            do_vld_pre3 <= do_vld_pre2;
            do_vld      <= do_vld_pre3;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate Mult core

    NFU_MULT_RE U_NFU_MULT_RE (
      .clk(clk),    // input wire CLK
      .a(A_re),        // input wire [11 : 0] A
      .sclr(rst),  // input wire SCLR
      .p(P_re)        // output wire [23 : 0] P
    );

    NFU_MULT_IM U_NFU_NULT_IM (
      .clk(clk),    // input wire CLK
      .a(A_im),        // input wire [11 : 0] A
      .sclr(rst),  // input wire SCLR
      .p(P_im)        // output wire [23 : 0] P
    );

endmodule