//% @file psu.v
//% @brief Implementation file of Packet Search Unit(PSU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-20

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Packet Search Unit(PSU) finish the packet search for receiver using a 2-level
//% LSR.
//% 
//% **Timing**
//% 
//% 1. delay the input data to the output port using a 2-level LSR 
//% 2. calculate the correlation of input data & the 1st LSR's output, detect
//%    the start point of a new frame
//% 
//% @note in the C program test, packet_start = x(the xth sample); 
//%       in verilog, packet_start = 1385(the 1385th samples)
module PSU (
    input                        clk,           //% working clock
    input                        rst,           //% synchronous reset, active high
    input        signed  [11:0]  di_re,         //% received data, real part
    input        signed  [11:0]  di_im,         //% received data, image part
    output  reg  signed  [11:0]  do_re,         //% output data, real part
    output  reg  signed  [11:0]  do_im,         //% output data, image part
    output  reg                  packet_start   //% start flag of a new frame
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // calculate the corr of new samples

    wire  signed  [11:0]  data1_re;     //% 1st level buffer output, real part
    wire  signed  [11:0]  data1_im;     //% 1st level buffer output, image part
    wire  signed  [11:0]  data2_re;     //% 2nd level buffer output, real part
    wire  signed  [11:0]  data2_im;     //% 2nd level buffer output, image part

    reg   signed  [31:0]  s_a_tdata;    //% complex multiplier input channel a
    reg   signed  [31:0]  s_b_tdata;    //% complex multiplier input channel b
    //% generate the input data to complex mulitplier (AXI4 BUS format)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_a_tdata <= 0;
            s_b_tdata <= 0;
        end
        else begin
            s_a_tdata <= {4'b0, di_im, 4'b0, di_re};
            s_b_tdata <= {4'b0, -data1_im, 4'b0, data1_re};
        end
    end

    wire        s_a_tvalid;     //% channel a data valid flag
    wire        s_b_tvalid;     //% channel b data valid flag
    assign s_a_tvalid = 1'b1;   //% channel a's data is always valid
    assign s_b_tvalid = 1'b1;   //% channel b's data is always valid

    wire  signed  [63:0]  m_dout_tdata;     //% output of multiplier
    wire                  m_dout_tvalid;    //% valid flag of multiplier output

    reg   signed  [24:0]  corr_re;      //% real part of correlation
    reg   signed  [24:0]  corr_im;      //% image part of correlation
    //% get the real & image part of correlation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            corr_re <= 0;
            corr_im <= 0;
        end
        else begin
            if (m_dout_tdata[24] == 0 && m_dout_tvalid) begin
                corr_re <= m_dout_tdata[24:0];
            end
            else if (m_dout_tvalid) begin
                corr_re <= 25'd33554431 -  m_dout_tdata[24:0] + 1;
            end
            if (m_dout_tdata[56] == 0 && m_dout_tvalid) begin
                corr_im <= m_dout_tdata[56:32];
            end
            else if (m_dout_tvalid) begin
                corr_im <= 25'd33554431 - m_dout_tdata[56:32] + 1;
            end
        end
    end

    reg   signed  [25:0]  new_corr;     //% new correlation value
    //% calculate the new value of correlation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            new_corr <= 0;
        end
        else begin
            new_corr <= corr_re + corr_im;
        end
    end

    //--------------------------------------------------------------------------
    // calcualte the sum of all correlation samples

    wire signed [25:0]    pre_corr;     //% correlation samples to be shifted 
                                        //% out from correlation buffer

    reg  signed  [34:0]    corr_sum;    //% sum of all correlation in the buffer
    //% calculate the sum of all correlation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            corr_sum <= 0;
        end
        else begin
            corr_sum <= corr_sum - pre_corr + new_corr;
        end
    end

    //--------------------------------------------------------------------------
    // find the start point of frame

    localparam      THRESHOLD = `N * 1578 * 1578 / 5 * 2;      //% threshold
    localparam      CNT_MAX = `N / 2;               //% max value of counter
    reg     [8:0]   cnt;                            //% counter to detect a period
    //% get the value of cnt
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (corr_sum > THRESHOLD) begin
                if (cnt == CNT_MAX) begin
                    cnt <= CNT_MAX;
                end
                else begin
                    cnt <= cnt + 1;
                end
            end
            else begin
                cnt <= 0;
            end
        end
    end

    //% find the start point of a new data frame
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            packet_start <= 0;
        end
        else begin
            if (cnt == CNT_MAX - 1) begin
                packet_start <= 1;
            end
            else begin
                packet_start <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // output the input through 2 level buffer

    //% generate the output data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= data2_re;
            do_im <= data2_im;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the RAM-based Shift Reg IP core

    // 1st layer shift reg
    DATA_SHIFT_RAM1_RE U_DATA_SHIFT_RAM1_RE (
        .d(di_re),      // input wire [11 : 0] d
        .clk(clk),  // input wire CLK
        .q(data1_re)      // output wire [11 : 0] q
    );

    DATA_SHIFT_RAM1_IM U_DATA_SHIFT_RAM1_IM (
        .d(di_im),      // input wire [11 : 0] d
        .clk(clk),  // input wire CLK
        .q(data1_im)      // output wire [11 : 0] q
    );

    // 2nd layer shift reg
    DATA_SHIFT_RAM2_RE U_DATA_SHIFT_RAM2_RE (
        .d(data1_re),      // input wire [11 : 0] d
        .clk(clk),  // input wire CLK
        .q(data2_re)      // output wire [11 : 0] q
    );

    DATA_SHIFT_RAM2_IM U_DATA_SHIFT_RAM2_IM (
        .d(data1_im),      // input wire [11 : 0] d
        .clk(clk),  // input wire CLK
        .q(data2_im)      // output wire [11 : 0] q
    );

    //--------------------------------------------------------------------------
    // instantiate the complex multiplier IP core

    CORR U_CORR (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        
        .m_axis_dout_tvalid(m_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    CORR_SUM U_CORR_SUM (
        .d(new_corr),      // input wire [25 : 0] d
        .clk(clk),  // input wire CLK
        .q(pre_corr)      // output wire [25 : 0] q
    );

endmodule