//% @file pvds.v
//% @brief Implementation file of Payload Valid Data Select(PVDS) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-09

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload Valid Data Select(PVDS) drop the invalid data at the front and end
//% of 512 input samples.
//% 
//% 512 = 16 + 480 + 16, drop the 16 invalid data.
module PVDS (
    input                        clk,       //% working clock
    input                        rst,       //% reset, active high
    input        signed  [13:0]  di_re,     //% input data real part
    input        signed  [13:0]  di_im,     //% input data image part
    input                        di_vld,    //% input data valid
    output  reg  signed  [13:0]  do_re,     //% output valid payload data real part
    output  reg  signed  [13:0]  do_im,     //% output valid payload data image part
    output  reg                  do_vld     //% output data valid
    );

//=============================================================================
// Main Body of Code

    localparam  SC_CNT_MAX = `N - 1;
    localparam  STR = 15;
    localparam  END = 495;

    reg  [8:0]  sc_cnt; // sub-carriers counter

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sc_cnt <= SC_CNT_MAX;
        end
        else begin
            if (di_vld) begin
                sc_cnt <= sc_cnt + 1;
            end
            else begin
                sc_cnt <= SC_CNT_MAX;
            end
        end
    end

    reg  [3:0]  sym_cnt;   // symbol counter

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sym_cnt <= 0;
        end
        else begin
            if (di_vld && sc_cnt == SC_CNT_MAX) begin
                sym_cnt <= sym_cnt + 1;
            end
        end
    end

    //---------------------------------------------------------------------------
    // output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= di_re;
            do_im <= di_im;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            // original payload length = 8640 bits --> 5 symbols
            if (sc_cnt >= STR && sc_cnt < END && sym_cnt <= 5) begin
                do_vld <= 1;
            end
            else begin
                do_vld <= 0;
            end
        end
    end

endmodule