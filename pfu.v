//% @file power_fix.v
//% @brief Implementation file of power fix unit(PFU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-12-31

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Power Fix Unit(PFU) finish the fix of power in transmitter.
//% 
//% because the power of ifft's output is 1/sqrt(N) compared to input, so this 
//% module multiply the sqrt(N) to keep the power unchanged.
//% 
//% sqrt(512) = 22.627(float) --> (fix point) 22.5 = 16 + 4 + 2 + 1/2, use shifting
//% & adding instead of multilier because the multiplier is constant number.
//% 
//% @note mulitipling sqrt(512) increase the bit width of output, do_re/im is still
//%       12 bits because of DAC. (need saturation operation additionally).
module PFU(
    input                        clk,       //% woring clock
    input        signed  [11:0]  di_re,     //% input data_re
    input        signed  [11:0]  di_im,     //% input data_im
    input                        di_vld,    //% input data valid

    output  reg  signed [11:0]   do_re,     //% output data_re
    output  reg  signed [11:0]   do_im,     //% output data_im
    output  reg                  do_vld     //% output data valid
    );

//==============================================================================
// Main Body of Code

    reg  signed  [15:0]  di_re_ls4;  //% di_re left shift 4 bits
    reg  signed  [15:0]  di_re_ls2;  //% di_re left shift 2 bits
    reg  signed  [15:0]  di_re_ls1;  //% di_re left shift 1 bit
    reg  signed  [15:0]  di_re_rs1;  //% di_re right shift 1 bit

    reg  signed  [15:0]  di_im_ls4;  //% di_im left shift 4 bits
    reg  signed  [15:0]  di_im_ls2;  //% di_im left shift 2 bits
    reg  signed  [15:0]  di_im_ls1;  //% di_im left shift 1 bit
    reg  signed  [15:0]  di_im_rs1;  //% di_im right shift 1 bit

    // left shifting bits for di-re/di_im
    always @(posedge clk) begin
        if (di_vld) begin
            di_re_ls4 <= di_re << 4;
            di_re_ls2 <= di_re << 2;
            di_re_ls1 <= di_re << 1;
            di_re_rs1 <= di_re >>> 1;
            di_im_ls4 <= di_im << 4;
            di_im_ls2 <= di_im << 2;
            di_im_ls1 <= di_im << 1;
            di_im_rs1 <= di_im >>> 1;
        end
        else begin
            di_re_ls4 <= 0;
            di_re_ls2 <= 0;
            di_re_ls1 <= 0;
            di_re_rs1 <= 0;
            di_im_ls4 <= 0;
            di_im_ls2 <= 0;
            di_im_ls1 <= 0;
            di_im_rs1 <= 0;
        end
    end

    reg  signed  [15:0]  do_re_tmp1;
    reg  signed  [15:0]  do_re_tmp2;
    reg  signed  [15:0]  do_re_tmp3;
    reg  signed  [15:0]  do_im_tmp1;
    reg  signed  [15:0]  do_im_tmp2;
    reg  signed  [15:0]  do_im_tmp3;

    //% get do_re/im
    always @(posedge clk) begin
        // re
        do_re_tmp1 <= di_re_ls4 + di_re_ls2;
        do_re_tmp2 <= di_re_ls1 + di_re_rs1;
        do_re_tmp3 <= do_re_tmp1 + do_re_tmp2;
        // im
        do_im_tmp1 <= di_im_ls4 + di_im_ls2;
        do_im_tmp2 <= di_im_ls1 + di_im_rs1;
        do_im_tmp3 <= do_im_tmp2 + do_im_tmp1;
    end

    always @(posedge clk) begin
        if (do_re_tmp3 > 2047) begin
            do_re <= 2047;
        end
        else if (do_re_tmp3 < -2047) begin
            do_re <= -2047;
        end
        else begin
            do_re <= do_re_tmp3;
        end
    end

    always @(posedge clk) begin
        if (do_im_tmp3 > 2047) begin
            do_im <= 2047;
        end
        else if (do_im_tmp3 < -2047) begin
            do_im <= -2047;
        end
        else begin
            do_im <= do_im_tmp3;
        end
    end

    reg  do_vld_tmp1;
    reg  do_vld_tmp2;
    reg  do_vld_tmp3;

    //% do_vld is 4 clk later to di_vld
    always @(posedge clk) begin
        do_vld_tmp1 <= di_vld;
        do_vld_tmp2 <= do_vld_tmp1;
        do_vld_tmp3 <= do_vld_tmp2;
        do_vld <= do_vld_tmp3;
    end

endmodule