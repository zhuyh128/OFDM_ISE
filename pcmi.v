//% @file pcmi.v
//% @brief Implementation file of Payload Mi(PCMI) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-16

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Payload Calculate Mi(PCMI) calculate the mi for different modulatin type.
//% 
//% save input into a FIFO, then read out one data every M clock cycle, for
//% 16QAM, M = 4.
//% 
//% m3 = abs(di_re) - 2;  -> for version1.1
//% m2 = di_re;
//% m1 = abs(di_im) - 2;
//% m0 = di_im;
//% 
//% @note only support 16QAM now!
//% @note di_re/im [10:0] is fractional part
//% @note number of input data(2400) < the depth of FIFO (4096).
module PCMI (
    input                        clk,
    input                        rst,
    input        signed  [14:0]  di_re,
    input        signed  [14:0]  di_im,
    input                        di_vld,
    output  reg  signed  [14:0]  do,
    output  reg                  do_vld
    );

//=============================================================================
// Main Body of Code

    /**
     * 1. save input data into a FIFO
     */
    wire         full_re;
    reg  [14:0]  din_re;
    reg          wr_en_re;

    wire         full_im;
    reg  [14:0]  din_im;
    reg          wr_en_im;


    localparam   CNT_MAX = 2400;
    reg  [11:0]  wr_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 0;
        end
        else begin
            if (di_vld && wr_cnt < CNT_MAX) begin
                wr_cnt <= wr_cnt + 1;
            end
            else begin
                wr_cnt <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_re <= 0;
            din_im <= 0;
            wr_en_re <= 0;
            wr_en_im <= 0;
        end
        else begin
            din_re <= di_re;
            din_im <= di_im;
            // real part
            if (di_vld && !full_re && wr_cnt < CNT_MAX) begin
                wr_en_re <= 1;
            end
            else begin
                wr_en_re <= 0;
            end
            // imag part
            if (di_vld && !full_im && wr_cnt <CNT_MAX) begin
                wr_en_im <= 1;
            end
            else begin
                wr_en_im <= 0;
            end
        end
    end

    /**
     * 2. read one data out from FIFO every 4 clock
     */
    wire         empty_re;
    reg          rd_en_re;
    wire [14:0]  dout_re;
    wire         valid_re;
    wire         empty_im;
    reg          rd_en_im;
    wire [14:0]  dout_im;
    wire         valid_im;

    localparam  RD_CNT_MAX = 3;
    reg  [3:0]  rd_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en_re <= 0;
            rd_en_im <= 0;
        end
        else begin
            // real part
            if (!empty_re && rd_cnt == RD_CNT_MAX-1) begin
                rd_en_re <= 1;
            end
            else begin
                rd_en_re <= 0;
            end
            // imag part
            if (!empty_im && rd_cnt == RD_CNT_MAX-1) begin
                rd_en_im <= 1;
            end
            else begin
                rd_en_im <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_cnt <= RD_CNT_MAX;
        end
        else begin
            if (!empty_re && rd_cnt == RD_CNT_MAX) begin
                rd_cnt <= 0;
            end
            else if (!empty_re) begin
                rd_cnt <= rd_cnt + 1;
            end
            else begin
                rd_cnt <= RD_CNT_MAX;
            end
        end
    end

    /**
     * 3. calculate m3, m2, m1, m0
     * 
     * 3Q11 format
     * 2.0 --> 0010_0000_0000_000
     */
    reg  signed  [14:0]  m3;
    reg  signed  [14:0]  m2;
    reg  signed  [14:0]  m1;
    reg  signed  [14:0]  m0;

    localparam  INTEGER2 = 15'b0010_0000_0000_000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            m3 <= 0;
            m2 <= 0;
            m1 <= 0;
            m0 <= 0;
        end
        else begin
            // m3, for d0
            if (dout_re[14] >  0) begin
                m2 <= 16'b1000_0000_0000_0000 - dout_re - INTEGER2;  // in version1.0, here should be m3
            end
            else begin
                m2 <= dout_re - INTEGER2;  // in version1.0, here should be m3
            end
            // m2, for d1
            m3 <= dout_re;  // in version1.0, here should be m2
            // m1, for d2
            if (dout_im[14] > 0) begin
                m0 <= 16'b1000_0000_0000_0000 - dout_im - INTEGER2; // in version1.0, here should be m1
            end
            else begin
                m0 <= dout_im - INTEGER2;  // in version1.0, here should be m1
            end
            // m0, for d3
            m1 <= dout_im;  // in version1.0, here should be m0
        end
    end

    /**
     * 4. output result
     */
    reg  m3_vld;
    reg  m2_vld;
    reg  m1_vld;
    reg  m0_vld;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            m3_vld <= 0;
            m2_vld <= 0;
            m1_vld <= 0;
            m0_vld <= 0;
        end
        else begin
            m3_vld <= valid_re;
            m2_vld <= m3_vld;
            m1_vld <= m2_vld;
            m0_vld <= m1_vld;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            case (1'b1)
                m3_vld:  do <= m3;
                m2_vld:  do <= m2;
                m1_vld:  do <= m1;
                m0_vld:  do <= m0;
                default: do <= 0;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            do_vld <= m3_vld || m2_vld || m1_vld || m0_vld;
        end
    end

    //-------------------------------------------------------------------------
    // instantiate the submodule

    PCMI_FIFO_RE U_PCMI_FIFO_RE (
        .clk(clk),      // input wire clk
        .rst(rst),      // input wire rst
        .din(din_re),      // input wire [14 : 0] din
        .wr_en(wr_en_re),  // input wire wr_en
        .rd_en(rd_en_re),  // input wire rd_en
        .dout(dout_re),    // output wire [14 : 0] dout
        .full(full_re),    // output wire full
        .empty(empty_re),  // output wire empty
        .valid(valid_re)  // output wire valid
    );

    PCMI_FIFO_IM U_PCMI_FIFO_IM (
        .clk(clk),      // input wire clk
        .rst(rst),      // input wire rst
        .din(din_im),      // input wire [14 : 0] din
        .wr_en(wr_en_im),  // input wire wr_en
        .rd_en(rd_en_im),  // input wire rd_en
        .dout(dout_im),    // output wire [14 : 0] dout
        .full(full_im),    // output wire full
        .empty(empty_im),  // output wire empty
        .valid(valid_im)  // output wire valid
    );

endmodule