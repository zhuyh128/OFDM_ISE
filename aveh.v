//% @file aveh.v
//% @brief Implementation file of Average of H(AVEH) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-23

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Average of H(AVEH) finish the average calcualtoin of 4 estimated H using 4
//% FIFO.
module AVEH (
    input                        clk,
    input                        rst,
    input        signed  [11:0]  din_re,
    input        signed  [11:0]  din_im,
    input                        din_vld,
    output  reg  signed  [11:0]  dout_re,
    output  reg  signed  [11:0]  dout_im,
    output  reg                  dout_vld
    );

//=============================================================================
// Main Body of code

    //-------------------------------------------------------------------------
    // 1st. save 4 symbols into 4 FIFO

    localparam   H_CNT_MAX = `N * 4 + 1;
    reg  [11:0]  H_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_cnt <= 0;
        end
        else begin
            if (H_cnt == H_CNT_MAX) begin
                H_cnt <= H_CNT_MAX;
            end
            else if (din_vld) begin
                H_cnt <= H_cnt + 1;
            end
        end
    end

    wire                  din_vld_dly1;
    wire  signed  [11:0]  din_re_dly1;
    wire  signed  [11:0]  din_im_dly1;

    DLY1 #(.WIDTH(1))  u_din_vld_dly1 (
        .clk(clk),
        .rst(rst),
        .din(din_vld),
        .dout(din_vld_dly1)
        );

    DLY1 #(.WIDTH(12))  u_din_re_dly1 (
        .clk(clk),
        .rst(rst),
        .din(din_re),
        .dout(din_re_dly1)
        );

    DLY1 #(.WIDTH(12))  u_din_im_dly1 (
        .clk(clk),
        .rst(rst),
        .din(din_im),
        .dout(din_im_dly1)
        );

    //--------------------------------------------------
    // real part

    wire                 h1re_full;
    reg                  h1re_wr_en;
    reg  signed  [11:0]  h1re_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h1re_wr_en <= 0;
            h1re_din <= 0;
        end
        else begin
            if (!h1re_full && H_cnt >= 1 && H_cnt <= `N) begin
                h1re_wr_en <= 1;
                h1re_din <= din_re_dly1;
            end
            else begin
                h1re_wr_en <= 0;
                h1re_din <= 0;
            end
        end
    end

    wire                 h2re_full;
    reg                  h2re_wr_en;
    reg  signed  [11:0]  h2re_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h2re_wr_en <= 0;
            h2re_din <= 0;
        end
        else begin
            if (!h2re_full && H_cnt >= `N+1 && H_cnt <= `N*2) begin
                h2re_wr_en <= 1;
                h2re_din <= din_re_dly1;
            end
            else begin
                h2re_wr_en <= 0;
                h2re_din <= 0;
            end
        end
    end

    wire                 h3re_full;
    reg                  h3re_wr_en;
    reg  signed  [11:0]  h3re_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h3re_wr_en <= 0;
            h3re_din <= 0;
        end
        else begin
            if (!h3re_full && H_cnt >= `N*2+1 && H_cnt <= `N*3) begin
                h3re_wr_en <= 1;
                h3re_din <= din_re_dly1;
            end
            else begin
                h3re_wr_en <= 0;
                h3re_din <= 0;
            end
        end
    end

    wire                 h4re_full;
    reg                  h4re_wr_en;
    reg  signed  [11:0]  h4re_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h4re_wr_en <= 0;
            h4re_din <= 0;
        end
        else begin
            if (!h4re_full && H_cnt >= `N*3+1 && H_cnt <= `N*4) begin
                h4re_wr_en <= 1;
                h4re_din <= din_re_dly1;
            end
            else begin
                h4re_wr_en <= 0;
                h4re_din <= 0;
            end
        end
    end

    //--------------------------------------------------
    // image part

    wire                 h1im_full;
    reg                  h1im_wr_en;
    reg  signed  [11:0]  h1im_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h1im_wr_en <= 0;
            h1im_din <= 0;
        end
        else begin
            if (!h1im_full && H_cnt >= 1 && H_cnt <= `N) begin
                h1im_wr_en <= 1;
                h1im_din <= din_im_dly1;
            end
            else begin
                h1im_wr_en <= 0;
                h1im_din <= 0;
            end
        end
    end

    wire                 h2im_full;
    reg                  h2im_wr_en;
    reg  signed  [11:0]  h2im_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h2im_wr_en <= 0;
            h2im_din <= 0;
        end
        else begin
            if (!h2im_full && H_cnt >= `N+1 && H_cnt <= `N*2) begin
                h2im_wr_en <= 1;
                h2im_din <= din_im_dly1;
            end
            else begin
                h2im_wr_en <= 0;
                h2im_din <= 0;
            end
        end
    end

    wire                 h3im_full;
    reg                  h3im_wr_en;
    reg  signed  [11:0]  h3im_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h3im_wr_en <= 0;
            h3im_din <= 0;
        end
        else begin
            if (!h3im_full && H_cnt >= `N*2+1 && H_cnt <= `N*3) begin
                h3im_wr_en <= 1;
                h3im_din <= din_im_dly1;
            end
            else begin
                h3im_wr_en <= 0;
                h3im_din <= 0;
            end
        end
    end

    wire                 h4im_full;
    reg                  h4im_wr_en;
    reg  signed  [11:0]  h4im_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h4im_wr_en <= 0;
            h4im_din <= 0;
        end
        else begin
            if (!h4im_full && H_cnt >= `N*3+1 && H_cnt <= `N*4) begin
                h4im_wr_en <= 1;
                h4im_din <= din_im_dly1;
            end
            else begin
                h4im_wr_en <= 0;
                h4im_din <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 2nd. read out the 4 symbols at the same time

    //---------------------------------------------
    // real part

    wire                  h1re_empty;
    reg                   h1re_rd_en;
    wire                  h1re_valid;
    wire  signed  [11:0]  h1re_dout;

    wire                  h2re_empty;
    reg                   h2re_rd_en;
    wire                  h2re_valid;
    wire  signed  [11:0]  h2re_dout;

    wire                  h3re_empty;
    reg                   h3re_rd_en;
    wire                  h3re_valid;
    wire  signed  [11:0]  h3re_dout;

    wire                  h4re_empty;
    reg                   h4re_rd_en;
    wire                  h4re_valid;
    wire  signed  [11:0]  h4re_dout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h1re_rd_en <= 0;
            h2re_rd_en <= 0;
            h3re_rd_en <= 0;
            h4re_rd_en <= 0;
        end
        else begin
            if (H_cnt > `N*4 && !h1re_empty) begin
                h1re_rd_en <= 1;
            end
            else begin
                h1re_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h2re_empty) begin
                h2re_rd_en <= 1;
            end
            else begin
                h2re_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h3re_empty) begin
                h3re_rd_en <= 1;
            end
            else begin
                h3re_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h4re_empty) begin
                h4re_rd_en <= 1;
            end
            else begin
                h4re_rd_en <= 0;
            end
        end
    end

    //---------------------------------------------
    // image part

    wire                  h1im_empty;
    reg                   h1im_rd_en;
    wire                  h1im_valid;
    wire  signed  [11:0]  h1im_dout;

    wire                  h2im_empty;
    reg                   h2im_rd_en;
    wire                  h2im_valid;
    wire  signed  [11:0]  h2im_dout;

    wire                  h3im_empty;
    reg                   h3im_rd_en;
    wire                  h3im_valid;
    wire  signed  [11:0]  h3im_dout;

    wire                  h4im_empty;
    reg                   h4im_rd_en;
    wire                  h4im_valid;
    wire  signed  [11:0]  h4im_dout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            h1im_rd_en <= 0;
            h2im_rd_en <= 0;
            h3im_rd_en <= 0;
            h4im_rd_en <= 0;
        end
        else begin
            if (H_cnt > `N*4 && !h1im_empty) begin
                h1im_rd_en <= 1;
            end
            else begin
                h1im_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h2im_empty) begin
                h2im_rd_en <= 1;
            end
            else begin
                h2im_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h3im_empty) begin
                h3im_rd_en <= 1;
            end
            else begin
                h3im_rd_en <= 0;
            end
            if (H_cnt > `N*4 && !h4im_empty) begin
                h4im_rd_en <= 1;
            end
            else begin
                h4im_rd_en <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 3rd. calculate the average of H~

    reg  signed  [12:0]  H_re_sum1;
    reg  signed  [12:0]  H_re_sum2;
    reg  signed  [13:0]  H_re_sum3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_re_sum1 <= 0;
            H_re_sum2 <= 0;
            H_re_sum3 <= 0;
        end
        else begin
            H_re_sum1 <= h1re_dout + h2re_dout;
            H_re_sum2 <= h3re_dout + h4re_dout;
            H_re_sum3 <= H_re_sum1 + H_re_sum2;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_re <= 0;
        end
        else begin
            dout_re <= H_re_sum3 >> 2;
        end
    end

    reg  signed  [12:0]  H_im_sum1;
    reg  signed  [12:0]  H_im_sum2;
    reg  signed  [13:0]  H_im_sum3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_im_sum1 <= 0;
            H_im_sum2 <= 0;
            H_im_sum3 <= 0;
        end
        else begin
            H_im_sum1 <= h1im_dout + h2im_dout;
            H_im_sum2 <= h3im_dout + h4im_dout;
            H_im_sum3 <= H_im_sum1 + H_im_sum2;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_im <= 0;
        end
        else begin
            dout_im <= H_im_sum3 >> 2;
        end
    end

    reg     dout_vld_pre1;
    reg     dout_vld_pre2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_vld_pre1 <= 0;
            dout_vld_pre2 <= 0;
            dout_vld <= 0;
        end
        else begin
            dout_vld_pre1 <= h1re_valid;
            dout_vld_pre2 <= dout_vld_pre1;
            dout_vld <= dout_vld_pre2;
        end
    end

    //-------------------------------------------------------------------------
    // instantiate IP core

    CEST_H_RE_FIFO1 U_CEST_H_RE_FIFO1 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h1re_din),      // input wire [11 : 0] din
        .wr_en(h1re_wr_en),  // input wire wr_en
        .rd_en(h1re_rd_en),  // input wire rd_en
        .dout(h1re_dout),    // output wire [11 : 0] dout
        .full(h1re_full),    // output wire full
        .empty(h1re_empty),  // output wire empty
        .valid(h1re_valid)  // output wire valid
    );

    CEST_H_RE_FIFO2 U_CEST_H_RE_FIFO2 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h2re_din),      // input wire [11 : 0] din
        .wr_en(h2re_wr_en),  // input wire wr_en
        .rd_en(h2re_rd_en),  // input wire rd_en
        .dout(h2re_dout),    // output wire [11 : 0] dout
        .full(h2re_full),    // output wire full
        .empty(h2re_empty),  // output wire empty
        .valid(h2re_valid)  // output wire valid
    );

    CEST_H_RE_FIFO3 U_CEST_H_RE_FIFO3 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h3re_din),      // input wire [11 : 0] din
        .wr_en(h3re_wr_en),  // input wire wr_en
        .rd_en(h3re_rd_en),  // input wire rd_en
        .dout(h3re_dout),    // output wire [11 : 0] dout
        .full(h3re_full),    // output wire full
        .empty(h3re_empty),  // output wire empty
        .valid(h3re_valid)  // output wire valid
    );

    CEST_H_RE_FIFO4 U_CEST_H_RE_FIFO4 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h4re_din),      // input wire [11 : 0] din
        .wr_en(h4re_wr_en),  // input wire wr_en
        .rd_en(h4re_rd_en),  // input wire rd_en
        .dout(h4re_dout),    // output wire [11 : 0] dout
        .full(h4re_full),    // output wire full
        .empty(h4re_empty),  // output wire empty
        .valid(h4re_valid)  // output wire valid
    );

    CEST_H_IM_FIFO1 U_CEST_H_IM_FIFO1 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h1im_din),      // input wire [11 : 0] din
        .wr_en(h1im_wr_en),  // input wire wr_en
        .rd_en(h1im_rd_en),  // input wire rd_en
        .dout(h1im_dout),    // output wire [11 : 0] dout
        .full(h1im_full),    // output wire full
        .empty(h1im_empty),  // output wire empty
        .valid(h1im_valid)  // output wire valid
    );

    CEST_H_IM_FIFO2 U_CEST_H_IM_FIFO2 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h2im_din),      // input wire [11 : 0] din
        .wr_en(h2im_wr_en),  // input wire wr_en
        .rd_en(h2im_rd_en),  // input wire rd_en
        .dout(h2im_dout),    // output wire [11 : 0] dout
        .full(h2im_full),    // output wire full
        .empty(h2im_empty),  // output wire empty
        .valid(h2im_valid)  // output wire valid
    );

    CEST_H_IM_FIFO3 U_CEST_H_IM_FIFO3 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h3im_din),      // input wire [11 : 0] din
        .wr_en(h3im_wr_en),  // input wire wr_en
        .rd_en(h3im_rd_en),  // input wire rd_en
        .dout(h3im_dout),    // output wire [11 : 0] dout
        .full(h3im_full),    // output wire full
        .empty(h3im_empty),  // output wire empty
        .valid(h3im_valid)  // output wire valid
    );

    CEST_H_IM_FIFO4 U_CEST_H_IM_FIFO4 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(h4im_din),      // input wire [11 : 0] din
        .wr_en(h4im_wr_en),  // input wire wr_en
        .rd_en(h4im_rd_en),  // input wire rd_en
        .dout(h4im_dout),    // output wire [11 : 0] dout
        .full(h4im_full),    // output wire full
        .empty(h4im_empty),  // output wire empty
        .valid(h4im_valid)  // output wire valid
    );
endmodule