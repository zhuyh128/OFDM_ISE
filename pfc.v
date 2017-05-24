//% @file pfc.v
//% @brief Implementation file of Payload Fraction Convert(PFC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-15

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload Fraction Convert(PFC) convert payload into integer + fraction format.
//% 
//% do_re = di_re/1578
//% do_im = di_im/1578
//% 
//% output format: 4 bits integer + 11 bits fraction, in 2's complement
module PFC (
    input                        clk,
    input                        rst,
    input        signed  [13:0]  di_re,
    input        signed  [13:0]  di_im,
    input                        di_vld,
    output  reg  signed  [14:0]  do_re,
    output  reg  signed  [14:0]  do_im,
    output  reg                  do_vld
    );

//=============================================================================
// Main Body of Code

    /**
     *  convert payload data into fix
     *  dividend 14 bits
     *  divisor 12 bits
     */
    reg                  pld_dividend_re_vld;
    reg  signed  [15:0]  pld_dividend_re;
    reg                  pld_divisor_re_vld;
    reg  signed  [15:0]  pld_divisor_re;
    reg                  pld_dividend_im_vld;
    reg  signed  [15:0]  pld_dividend_im;
    reg                  pld_divisor_im_vld;
    reg  signed  [15:0]  pld_divisor_im;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            pld_dividend_re <= 0;
            pld_divisor_re <= 0;
            pld_dividend_im <= 0;
            pld_divisor_im <= 0;
        end
        else begin
            if (di_vld) begin
                pld_dividend_re <= {2'b0, di_re};
                pld_divisor_re <= 16'sd1578;
                pld_dividend_im <= {2'b0, di_im};
                pld_divisor_im <= 16'sd1578;
            end
            else begin
                pld_dividend_re <= 0;
                pld_divisor_re <= 0;
                pld_dividend_im <= 0;
                pld_divisor_im <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            pld_dividend_re_vld <= 0;
            pld_divisor_re_vld <= 0;
            pld_dividend_im_vld <= 0;
            pld_divisor_im_vld <= 0;
        end
        else begin
            pld_dividend_re_vld <= di_vld;
            pld_divisor_re_vld <= di_vld;
            pld_dividend_im_vld <= di_vld;
            pld_divisor_im_vld <= di_vld;
        end
    end

    wire          pld_div_re_out_vld;
    wire  [31:0]  pld_div_re_out;
    wire          pld_div_im_out_vld;
    wire  [31:0]  pld_div_im_out;

    // 2's complement for integer & fraction
    // integer 4 bits in 2's complement
    // fraction 12 bits in 2's complement
    reg            pld_div_re_vld;
    reg    [3 :0]  pld_div_re_int;
    reg    [11:0]  pld_div_re_frac;
    reg            pld_div_im_vld;
    reg    [3 :0]  pld_div_im_int;
    reg    [11:0]  pld_div_im_frac;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            pld_div_re_int  <= 0;
            pld_div_re_frac <= 0;
            pld_div_im_int  <= 0;
            pld_div_im_frac <= 0;
        end
        else begin
            if (pld_div_re_out_vld) begin
                pld_div_re_int  <= pld_div_re_out[15:12];
                pld_div_re_frac <= pld_div_re_out[11: 0];
                pld_div_im_int  <= pld_div_im_out[15:12];
                pld_div_im_frac <= pld_div_im_out[11: 0];
            end
            else begin
                pld_div_re_int  <= 0;
                pld_div_re_frac <= 0;
                pld_div_im_int  <= 0;
                pld_div_im_frac <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            pld_div_re_vld <= 0;
            pld_div_im_vld <= 0;
        end
        else begin
            pld_div_re_vld <= pld_div_re_out_vld;
            pld_div_im_vld <= pld_div_re_out_vld;
        end
    end

    // final div result, 3Q11
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_vld <= pld_div_re_vld;
            // real part
            if (pld_div_re_int[3] > 0) begin  // -x.xxx
                do_re <= {{pld_div_re_int - 1}, pld_div_re_frac[10:0]};
            end
            else if (pld_div_re_int == 0 && pld_div_re_frac[11] > 0) begin  // -0.xxxx
                do_re <= {4'b1111, pld_div_re_frac[10:0]};
            end
            else begin  // +x.xxx
                do_re <= {pld_div_re_int, pld_div_re_frac[10:0]};
            end
            // imag part
            if (pld_div_im_int[3] > 0) begin
                do_im <= {{pld_div_im_int - 1}, pld_div_im_frac[10:0]};
            end
            else if (pld_div_im_int == 0 && pld_div_im_frac[11] > 0) begin
                do_im <= {4'b1111, pld_div_im_frac[10:0]};
            end
            else begin
                do_im <= {pld_div_im_int, pld_div_im_frac[10:0]};
            end
        end
    end  

    //-------------------------------------------------------------------------
    // instantiate the submodule

    PFC_DIV_RE U_PFC_DIV_RE (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(pld_divisor_re_vld),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(pld_divisor_re),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(pld_dividend_re_vld),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(pld_dividend_re),    // input wire [15 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(pld_div_re_out_vld),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(pld_div_re_out)            // output wire [31 : 0] m_axis_dout_tdata
    );

    PFC_DIV_IM U_PFC_DIV_IM (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(pld_divisor_im_vld),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(pld_divisor_im),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(pld_dividend_im_vld),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(pld_dividend_im),    // input wire [15 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(pld_div_im_out_vld),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(pld_div_im_out)            // output wire [31 : 0] m_axis_dout_tdata
    );

endmodule