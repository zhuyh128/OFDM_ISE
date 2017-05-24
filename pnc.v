//% @file pnc.v
//% @brief Implementation file of Payload Noise Calculation(PNC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-15

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

// Paload Noise Calculation(PNC) convert noise to fix point format,
// calculate the Kf
// 
// Kf = 1/n0 
//    = 1/(sigma2/1578) 
//    = 1578/sigma2
//    
module PNC (
    input                        clk,       //% working clock
    input                        rst,       //% reset, active high
    input        signed  [11:0]  di,        //% input square sigma
    input                        di_vld,    //% input data valid
    output  reg  signed  [11:0]  do,        //% output 
    output  reg                  do_vld     //% output data valid
    );

//=============================================================================
// Main Body of Code

    /**
     * 1. div for real & imag part
     */
    reg          dividend_tvalid;
    reg  [15:0]  dividend_tdata;
    reg          divisor_tvalid;
    reg  [15:0]  divisor_tdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dividend_tvalid <= 0;
            dividend_tdata  <= 0;
            divisor_tvalid  <= 0;
            divisor_tdata   <= 0;
        end
        else begin
            dividend_tvalid <= di_vld;
            dividend_tdata  <= 16'sd1578;
            divisor_tvalid  <= di_vld;
            divisor_tdata   <= {4'b0, di};
        end
    end

    /**
     * 2. choose the valid 480 sub-carriers in central
     */
    wire          dout_tvalid;
    wire  [31:0]  dout_tdata;

    reg  signed  [11:0]  quotient;
    reg                  quotient_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            quotient <= 0;
            quotient_vld <= 0;
        end
        else begin
            quotient <= dout_tdata[27:16];
            quotient_vld <= dout_tvalid;
        end
    end

    reg  [9:0]  out_cnt;
    localparam  START = 16;
    localparam  END   = 495;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt <= 0;
        end
        else begin
            if (quotient_vld) begin
                out_cnt <= out_cnt + 1;
            end
            else begin
                out_cnt <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
            do_vld <= 0;
        end
        else begin
            do <= quotient;
            if (out_cnt >= START && out_cnt <= END) begin
                do_vld <= 1;
            end
            else begin
                do_vld <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // instantiate the submodule

    PNC_DIV PNC_DIV (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(divisor_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(dividend_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(dout_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(dout_tdata)            // output wire [31 : 0] m_axis_dout_tdata
    );

endmodule