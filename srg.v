//% @file srg.v
//% @brief Implementation file of System Reset Generation(SCG) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-11

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% System Reset Generation (SRG) generate all the reset signal for both of
//% transmitter and receiver.
module SRG (
    input        clk_trans_sig,         //% input clk for transitter signal
    input        clk_trans_pld,         //% input clk for transmitter payload
    input        clk_recv,              //% input clk for receiver
    input        rst_i,                 //% input global reset
    output  reg  sys_rst_trans_sig,     //% output reset for transitter signal
    output  reg  sys_rst_trans_pld,     //% output reset for transitter
    output  reg  sys_rst_recv           //% output reset for receiver
    );

//==============================================================================
// Main Body of Code


    //----------------------------------------------------------
    // clock domian 1: transmitter 50 MHz for signal segment
    reg  rst_sig_r;

    always @(posedge clk_trans_sig or posedge rst_i) begin
        if (rst_i) begin
            // reset
            rst_sig_r <= 1'b1;
        end
        else begin
            rst_sig_r <= 1'b0;
        end
    end

    always @(posedge clk_trans_sig or posedge rst_i) begin
        if (rst_i) begin
            // reset
            sys_rst_trans_sig <= 1'b1;
        end
        else begin
            sys_rst_trans_sig <= rst_sig_r;
        end
    end

    //----------------------------------------------------------
    // clock domian 2: transmitter 150 MHz for payload segment
    reg  rst_pld_r;

    always @(posedge clk_trans_pld or posedge rst_i) begin
        if (rst_i) begin
            // reset
            rst_pld_r <= 1'b1;
        end
        else begin
            rst_pld_r <= 1'b0;
        end
    end

    always @(posedge clk_trans_pld or posedge rst_i) begin
        if (rst_i) begin
            // reset
            sys_rst_trans_pld <= 1'b1;
        end
        else begin
            sys_rst_trans_pld <= rst_pld_r;
        end
    end

    //----------------------------------------------------------
    // clock domian 3: receiver 150 MHz
    reg  rst_recv_r;

    always @(posedge clk_recv or posedge rst_i) begin
        if (rst_i) begin
            // reset
            rst_recv_r <= 1'b1;
        end
        else begin
            rst_recv_r <= 1'b0;
        end
    end

    always @(posedge clk_recv or posedge rst_i) begin
        if (rst_i) begin
            // reset
            sys_rst_recv <= 1'b1;
        end
        else begin
            sys_rst_recv <= rst_recv_r;
        end
    end

endmodule