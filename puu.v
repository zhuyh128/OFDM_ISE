//% @file puu.v
//% @brief Implementation file of Power Unfix Unit(PUU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-03
`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Power UNfix Unit (PUU) module finish the power unfix(divide 22.5)
//% 
//% using IP core to simplify the design at the cost of resource
//% 
//% @note sqrt(512) ~= 22.5, uisng 8 bits representing divisor(22.5)
module PUU (
    input                        clk,
    input                        rst,
    input        signed  [11:0]  di_re,
    input        signed  [11:0]  di_im,
    input                        di_vld,
    output  reg  signed  [11:0]  do_re,
    output  reg  signed  [11:0]  do_im,
    output  reg                  do_vld
    );

//==============================================================================
// Main Body of Code

    //------------------------------------------------------------
    // divide real part
    reg  [15:0]  s_re_dividend_tdata;
    reg          s_re_dividend_tvalid;
    reg  [7 :0]  s_re_divisor_tdata;
    reg          s_re_divisor_tvalid;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s_re_dividend_tdata <= 0;
            s_re_dividend_tvalid <= 0;
            s_re_divisor_tdata <= 0;
            s_re_divisor_tvalid <= 0;
        end
        else begin
            s_re_dividend_tdata <= {4'b0, di_re};
            s_re_dividend_tvalid <= di_vld;
            s_re_divisor_tdata <= 12'd45;   // 22.5 --> 45, representing in 8 bits
            s_re_divisor_tvalid <= di_vld;
        end
    end

    //-------------------------------------------------------------
    // divide image part
    reg  [15:0]  s_im_dividend_tdata;
    reg          s_im_dividend_tvalid;
    reg  [7 :0]  s_im_divisor_tdata;
    reg          s_im_divisor_tvalid;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s_im_dividend_tdata <= 0;
            s_im_dividend_tvalid <= 0;
            s_im_divisor_tdata <= 0;
            s_im_divisor_tvalid <= 0;
        end
        else begin
            s_im_dividend_tdata <= {4'b0, di_im};
            s_im_dividend_tvalid <= di_vld;
            s_im_divisor_tdata <= 12'd45;   // 22.5 --> 45, representing in 8 bits
            s_im_divisor_tvalid <= di_vld;
        end
    end

    //-------------------------------------------------------------
    // get output
    wire  [23:0]  m_re_dout_tdata;
    wire          m_re_dout_tvalid;

    wire  [23:0]  m_im_dout_tdata;
    wire          m_im_dout_tvalid;

    reg  signed  [11:0]  quotient_re;
    reg  signed  [11:0]  quotient_im;
    reg                  quotient_vld;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            quotient_re <= 0;
            quotient_im <= 0;
        end
        else begin
            quotient_re <= m_re_dout_tdata[19:8];
            quotient_im <= m_im_dout_tdata[19:8];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            quotient_vld <= 0;
        end
        else begin
            quotient_vld <= m_re_dout_tvalid;
        end
    end

    //------------------------------------------------------
    // fix 45 --> 22.5, left shift 1 bit

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= quotient_re << 1;
            do_im <= quotient_im << 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            do_vld <= quotient_vld;
        end
    end

    //-------------------------------------------------------------------------
    // instantiate the submodule

    PUU_DIVIDER_RE U_PUU_DIVIDER_RE (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(s_re_divisor_tvalid),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(s_re_divisor_tdata),      // input wire [7 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(s_re_dividend_tvalid),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(s_re_dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(m_re_dout_tvalid),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(m_re_dout_tdata)            // output wire [23 : 0] m_axis_dout_tdata
    );

    PUU_DIVIDER_IM U_PUU_DIVIDER_IM (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(s_im_divisor_tvalid),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata(s_im_divisor_tdata),      // input wire [7 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(s_im_dividend_tvalid),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata(s_im_dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(m_im_dout_tvalid),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(m_im_dout_tdata)            // output wire [23 : 0] m_axis_dout_tdata
    );

endmodule