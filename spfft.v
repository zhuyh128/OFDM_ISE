//% @file spfft.v
//% @brief Implementation file of Signal & Payload FFT(SPFFT) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-15

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Signal & Payload FFT(SPFFT) call FFTU submodule finish the FFT for signal &
//% payload (wrapper of FFT Unit for signal & preamble).
//% 
//% @note the signal & payload symbol number <= 7
//% 
//% @note first divide 22.5 to aviod overflow (inverse operation in transmitter)
module SPFFT (
    input                        clk,       //% working clock
    input                        rst,       //% synchornous reset, active high
    input        signed  [11:0]  di_re,     //% input signal & payload, real part
    input        signed  [11:0]  di_im,     //% input signal & payload, image part
    input                        di_vld,    //% input data valid flag
    output  reg  signed  [11:0]  do_re,     //% output data after FFT, real part
    output  reg  signed  [11:0]  do_im,     //% output data after FFT, image part
    output  reg                  do_vld     //% output data valid flag
    );

//==============================================================================
// Main Body of Code

    wire  signed  [21:0]  fft_do_re;
    wire  signed  [21:0]  fft_do_im;
    wire                  fft_do_vld;

    //% FFTU is unscale mode, output width is 22 bits.
    //% truncate 22 bits to 14 bits, pay attention to saturation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
            do_vld <= 0;
        end
        else begin
            // do_re
            if (fft_do_re > 2047) begin
                do_re <= 2047;
            end
            else if (fft_do_re < -2048) begin
                do_re <= -2048;
            end
            else begin
                do_re <= fft_do_re[11:0];
            end
            // do_im
            if (fft_do_im > 2047) begin
                do_im <= 2047;
            end
            else if (fft_do_im < -2048) begin
                do_im <= -2048;
            end
            else begin
                do_im <= fft_do_im[11:0];
            end
            // do_vld
            do_vld <= fft_do_vld;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate submodule

    wire  signed  [11:0]  PUUFFT_re;
    wire  signed  [11:0]  PUUFFT_im;
    wire                  PUUFFT_vld;

    PUU SPFFT_PUU (
        .clk(clk),
        .rst(rst),
        .di_re(di_re),
        .di_im(di_im),
        .di_vld(di_vld),
        .do_re(PUUFFT_re),
        .do_im(PUUFFT_im),
        .do_vld(PUUFFT_vld)
    );

    FFTU SPFFT_FFT (
        .clk(clk),   
        .rst(rst),   
        .di_re(PUUFFT_re), 
        .di_im(PUUFFT_im), 
        .di_vld(PUUFFT_vld),
        .do_re(fft_do_re), 
        .do_im(fft_do_im), 
        .do_vld(fft_do_vld) 
    );

endmodule