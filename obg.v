//% @file obg.v
//% @brief Implementation file of Original Bits Generator(OBG) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-23

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Original Bits Generator(PRG) finish the generation of original bits of PHY
//% frame.
//% 
//% **including 2 sub-module:**
//% 
//% 1. SSG (signal)
//% 2. PLG (payload)
module OBG (
    // SSG module ports
    input               ssg_clk,       //% working clock
    input               ssg_rst,       //% asynchronous reset, active high
    input   [15 : 0]    ssg_di_len,    //% length of PSDU
    input   [3  : 0]    ssg_di_type,   //% type of PSDU
    input               ssg_di_vld,    //% data input valid
    output  [5  : 0]    ssg_do_init,   //% last 6 bits of signal do
    output              ssg_do,        //% signal data output
    output              ssg_do_vld,    //% signal data output valid

    // for payload
    input               new_frame,     //% new frame arrive
    input               pld_clk,       //% working clock
    input               pld_rst,       //% reset, active high
    // output  reg         pld_rd_en
    output              pld_do,        //% payload data output
    output              pld_do_vld     //% payload data output valid
    );

//==============================================================================
// Main Body of Code
/*	 wire ssg_done_flag;
	 wire pld_done_flag;
	 reg ssg_done_rst;
	 reg pld_done_rst;*/
    //------------------------------------------------
    //% instantiate SSG module
    SSG U_SSG (
//		  .done_rst(ssg_done_rst),
        .clk(ssg_clk),
        .rst(ssg_rst),
        .di_len(ssg_di_len),
        .di_type(ssg_di_type),
        .di_vld(ssg_di_vld),
        .do_init(ssg_do_init),
        .do(ssg_do),
        .do_vld(ssg_do_vld)
//		  .done_flag(ssg_done_flag)
    );

    //% instantiate OPG module
    OPG U_OPG (
//		  .done_rst(pld_done_rst),
        .clk(pld_clk),
        .rst(pld_rst),
        .rd_en(new_frame),
        .do(pld_do),
        .do_vld(pld_do_vld)
//		  .done_flag(pld_done_flag)
        );
		 
/*	always @(posedge pld_clk or posedge ssg_clk) begin
	    if(pld_done_flag&&ssg_done_flag) begin
		     ssg_done_rst <= 1;
			  pld_done_rst <= 1;
		 end
		 
		 else begin
		     ssg_done_rst <= 0;
			  pld_done_rst <= 0;
		 end
	end
*/
    // always @(posedge pld_clk or posedge pld_rst) begin
    //     if (pld_rst) begin
    //         // reset
    //         pld_rd_en <= 0;
    //     end
    //     else begin
    //         pld_rd_en <= new_frame;
    //     end
    // end

endmodule
