//% @file scds.v
//% @brief Implementation file of Signal Constellation De-Scramble(SCDS) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-25

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Signal Constellation De-Scramble(SCDS) finish the constellation De-Scramble
//% for signal segment.
module SCDS (
    input                        clk,       //% working clock
    input                        rst,       //% reset, active high
    input        signed  [11:0]  di_re,     //% input to be de-scrambled real data
    input        signed  [11:0]  di_im,     //% input to be de-scrambled image data
    input                        di_vld,    //% di_re/im valid flag
    output  reg  signed  [11:0]  do_re,     //% ouptut de-scrambled real data
    output  reg  signed  [11:0]  do_im,     //% output de-scrambled image data
    output  reg                  do_vld     //% do_re/im valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // use a counter get indx = [16, 495]

    localparam  START = 15;     //% start point of de-scramble
    localparam  END   = 495;    //% end point of de-scramble
    reg  [9:0]  cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (di_vld) begin
                cnt <= cnt + 1;
            end
            else begin
                cnt <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // de-scramble

    reg    [0:12]  LFSR;

    wire  fbk1;
    wire  fbk2;

    assign fbk1 = LFSR[7] + LFSR[10] + LFSR[11] + LFSR[12];
    assign fbk2 = LFSR[6] + LFSR[9] + LFSR[10] + LFSR[11];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            LFSR <= 13'b1_1111_1111_1111;
        end
        else begin
            if (cnt > START && cnt < END) begin
                LFSR <= {fbk2, fbk1, LFSR[0:10]};
            end
            else begin
                LFSR <= 13'b1_1111_1111_1111;
            end
        end
    end

    // de-scramble
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            if (di_vld) begin
                case (LFSR[0:1])
                    2'b00: begin
                        do_re <= di_re;
                        do_im <= di_im;
                    end
                    2'b10: begin
                        do_re <= di_im;
                        do_im <= -di_re;
                    end
                    2'b01: begin
                        do_re <= -di_re;
                        do_im <= -di_im;
                    end
                    2'b11: begin
                        do_re <= -di_im;
                        do_im <= di_re;
                    end
                endcase
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            do_vld <= di_vld;
        end
    end

endmodule