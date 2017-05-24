//% @file fmac.v
//% @brief Implementation file of Fake MAC(fmac) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-04

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Fake MAC module for test, to be deleted
module FMAC (
    input                clk,             //% input clk
    input                rst,             //% input reset
    //input                start,
    output  reg          new_frame,       //% output for payload to start
    output  reg          frame_vld,       //% output for signal to start
    output  reg  [15:0]  frame_len,       //% output to signal
    output  reg  [03:0]  frame_type       //% output to signal
    );

	
//==============================================================================
// Main Body of Code

    //% detect pose edge of start
    reg  start_r1;
    reg  start_r2;
    wire start_pose;

    //--------   remove start_butten, set start signal instead of start butten    -----------
    reg start;
    integer cnt;
    localparam VALUE = 1200;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            start <= 0;
        end
        else begin
            if (cnt == VALUE) begin
                start <= 1;
            end
            else begin
                start <= 0;
            end
        end
    end
    //--------  remove start_butten   ------------




    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            start_r1 <= 0;
            start_r2 <= 0;
        end
        else begin
            start_r1 <= start;
            start_r2 <= start_r1;
        end
    end

    assign start_pose = start_r1 & (!start_r2);

    //% output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            new_frame <= 0;
        end
        else begin
            new_frame <= start_pose;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            frame_len <= 0;
            frame_type <= 0;
        end
        else begin
            frame_len <= 16'd10;
            frame_type <= 4'd0;
        end
    end

    reg   start_pose_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            start_pose_r <= 0;
            frame_vld <= 0;
        end
        else begin
            start_pose_r <= start_pose;
            frame_vld <= start_pose_r;
        end
    end

endmodule
