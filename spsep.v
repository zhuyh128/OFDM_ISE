//% @file spsep.v
//% @brief Implementation file of Signal & Payload Seperate(SPSEP) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-25

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Signal & Payload Seperate(SPDSP) seperate the input signal & payload into 2
//% data steam.
module SPSEP (
    input                        clk,               //% working clock
    input                        rst,               //% reset, active high
    input        signed  [11:0]  din_re,            //% input data
    input        signed  [11:0]  din_im,            //% input data
    input                        din_vld,           //% input data valid
    output  reg  signed  [11:0]  dout_signal_re,    //% output signal data
    output  reg  signed  [11:0]  dout_signal_im,    //% output signal data
    output  reg                  dout_signal_vld,   //% output signal data valid
    output  reg  signed  [11:0]  dout_payload_re,   //% output payload data
    output  reg  signed  [11:0]  dout_payload_im,   //% output payload data
    output  reg                  dout_payload_vld   //% output payload data valid
    );

//=============================================================================
// Main Body of Code
	 
	 reg  done_flag;				//Modified by baiyf
	 reg  done_rst;
	 
    wire  signed  [11:0]  data_re;
    wire  signed  [11:0]  data_im;

    DLY1 #(.WIDTH(12)) u_data_re (
        .clk(clk),
        .rst(rst||done_rst),
        .din(din_re),
        .dout(data_re)
    );

    DLY1 #(.WIDTH(12)) u_data_im (
        .clk(clk),
        .rst(rst||done_rst),
        .din(din_im),
        .dout(data_im)
    );

    //-------------------------------------------------------------------------
    // use a counter to divide input data, upstream logic input 7 symbols

    localparam   SIG_CNT_MAX = `N;
    localparam   PLD_CNT_MAX = `N*7;

    reg  [11:0]  cnt;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (din_vld) begin
                cnt <= cnt + 1;
            end
            else begin
                cnt <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // the 1st symbols is signal
    
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dout_signal_vld <= 0;
            dout_signal_re <= 0;
            dout_signal_im <= 0;
        end
        else begin
            if (cnt > 0 && cnt <= SIG_CNT_MAX) begin
                dout_signal_vld <= 1;
                dout_signal_re <= data_re;
                dout_signal_im <= data_im;
            end
            else begin
                dout_signal_vld <= 0;
                dout_signal_re <= 0;
                dout_signal_im <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // the 2nd ~ 7th symbols are payload

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dout_payload_vld <= 0;
            dout_payload_re <= 0;
            dout_payload_im <= 0;
        end
        else begin
            if (cnt > SIG_CNT_MAX && cnt <= PLD_CNT_MAX) begin
                dout_payload_vld <= 1;
                dout_payload_re <= data_re;
                dout_payload_im <= data_im;
            end
            else begin
                dout_payload_vld <= 0;
                dout_payload_re <= 0;
                dout_payload_im <= 0;
            end
        end
    end

	 always @(posedge clk or posedge rst or posedge done_rst) begin
	     if(rst||done_rst) begin
		      done_flag <= 0;
		  end
		  else begin
		      if(cnt == PLD_CNT_MAX)begin
				    done_flag <= 1;
				end
		  end
	 end
	 
	 always @(posedge clk) begin
	     if(done_flag) begin
		      done_rst <= 1;
		  end
		  else begin
		      done_rst <= 0;
		  end
	 end
	 
endmodule
