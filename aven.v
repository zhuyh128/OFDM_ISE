//% @file aven.v
//% @brief Implementation file of Average of Noise(AVEN) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-23

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Average of Noise(AVEN) finish the average calcualtoin of 4 estimated H 
//% using 4 FIFOs.  
module AVEN (
    input                        clk,
    input                        rst,
    input        signed  [11:0]  din,
    input                        din_vld,
    output  reg  signed  [11:0]  dout,
    output  reg                  dout_vld
    );

//=============================================================================
// Main Body of Code

    //-------------------------------------------------------------------------
    // 1st. save 4 symbols into 4 FIFO

    localparam   N_CNT_MAX = `N * 4 + 1;
    reg  [11:0]  N_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            N_cnt <= 0;
        end
        else begin
            if (N_cnt == N_CNT_MAX) begin
                N_cnt <= N_CNT_MAX;
            end
            else if (din_vld) begin
                N_cnt <= N_cnt + 1;
            end
        end
    end

    wire                  din_vld_dly1;
    wire  signed  [11:0]  din_dly1;

    DLY1 #(.WIDTH(1))  u_din_vld_dly1 (
        .clk(clk),
        .rst(rst),
        .din(din_vld),
        .dout(din_vld_dly1)
        );

    DLY1 #(.WIDTH(12))  u_din_dly1 (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(din_dly1)
        );

    //-----------------------------------------

    wire                 n1_full;
    reg                  n1_wr_en;
    reg  signed  [11:0]  n1_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            n1_wr_en <= 0;
            n1_din <= 0;
        end
        else begin
            if (!n1_full && N_cnt >= 1 && N_cnt <= `N) begin
                n1_wr_en <= 1;
                n1_din <= din_dly1;
            end
            else begin
                n1_wr_en <= 0;
                n1_din <= 0;
            end
        end
    end

    wire                 n2_full;
    reg                  n2_wr_en;
    reg  signed  [11:0]  n2_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            n2_wr_en <= 0;
            n2_din <= 0;
        end
        else begin
            if (!n2_full && N_cnt >= `N+1 && N_cnt <= `N*2) begin
                n2_wr_en <= 1;
                n2_din <= din_dly1;
            end
            else begin
                n2_wr_en <= 0;
                n2_din <= 0;
            end
        end
    end

    wire                 n3_full;
    reg                  n3_wr_en;
    reg  signed  [11:0]  n3_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            n3_wr_en <= 0;
            n3_din <= 0;
        end
        else begin
            if (!n3_full && N_cnt >= `N*2+1 && N_cnt <= `N*3) begin
                n3_wr_en <= 1;
                n3_din <= din_dly1;
            end
            else begin
                n3_wr_en <= 0;
                n3_din <= 0;
            end
        end
    end

    wire                 n4_full;
    reg                  n4_wr_en;
    reg  signed  [11:0]  n4_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            n4_wr_en <= 0;
            n4_din <= 0;
        end
        else begin
            if (!n4_full && N_cnt >= `N*3+1 && N_cnt <= `N*4) begin
                n4_wr_en <= 1;
                n4_din <= din_dly1;
            end
            else begin
                n4_wr_en <= 0;
                n4_din <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 2nd. read out the 4 symbols at the same time

    wire                  n1_empty;
    reg                   n1_rd_en;
    wire                  n1_valid;
    wire  signed  [11:0]  n1_dout;

    wire                  n2_empty;
    reg                   n2_rd_en;
    wire                  n2_valid;
    wire  signed  [11:0]  n2_dout;

    wire                  n3_empty;
    reg                   n3_rd_en;
    wire                  n3_valid;
    wire  signed  [11:0]  n3_dout;

    wire                  n4_empty;
    reg                   n4_rd_en;
    wire                  n4_valid;
    wire  signed  [11:0]  n4_dout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            n1_rd_en <= 0;
            n2_rd_en <= 0;
            n3_rd_en <= 0;
            n4_rd_en <= 0;
        end
        else begin
            if (N_cnt > `N*4 && !n1_empty) begin
                n1_rd_en <= 1;
            end
            else begin
                n1_rd_en <= 0;
            end
            if (N_cnt > `N*4 && !n2_empty) begin
                n2_rd_en <= 1;
            end
            else begin
                n2_rd_en <= 0;
            end
            if (N_cnt > `N*4 && !n3_empty) begin
                n3_rd_en <= 1;
            end
            else begin
                n3_rd_en <= 0;
            end
            if (N_cnt > `N*4 && !n4_empty) begin
                n4_rd_en <= 1;
            end
            else begin
                n4_rd_en <= 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 3rd. calculate the average of H~

    reg  signed  [12:0]  N_sum1;
    reg  signed  [12:0]  N_sum2;
    reg  signed  [13:0]  N_sum3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            N_sum1 <= 0;
            N_sum2 <= 0;
            N_sum3 <= 0;
        end
        else begin
            N_sum1 <= n1_dout + n2_dout;
            N_sum2 <= n3_dout + n4_dout;
            N_sum3 <= N_sum1 + N_sum2;
        end
    end

    reg  signed  [11:0]  sigma2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sigma2 <= 0;
        end
        else begin
            sigma2 <= N_sum3 >> 2;
        end
    end

    reg     sigma2_vld_pre1;
    reg     sigma2_vld_pre2;
    reg     sigma2_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sigma2_vld_pre1 <= 0;
            sigma2_vld_pre2 <= 0;
            sigma2_vld <= 0;
        end
        else begin
            sigma2_vld_pre1 <= n1_valid;
            sigma2_vld_pre2 <= sigma2_vld_pre1;
            sigma2_vld <= sigma2_vld_pre2;
        end
    end

    //-------------------------------------------------------------------------
    // 4th. in case of sigma2 == 0

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout <= 0;
            dout_vld <= 0;
        end
        else begin
            if (sigma2 == 0) begin
                dout <= 1;
            end
            else begin
                dout <= sigma2;
            end
            dout_vld <= sigma2_vld;
        end
    end

    //-------------------------------------------------------------------------
    // instantiate IP core

    CEST_N_FIFO1 U_CEST_N_FIFO1 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(n1_din),      // input wire [11 : 0] din
        .wr_en(n1_wr_en),  // input wire wr_en
        .rd_en(n1_rd_en),  // input wire rd_en
        .dout(n1_dout),    // output wire [11 : 0] dout
        .full(n1_full),    // output wire full
        .empty(n1_empty),  // output wire empty
        .valid(n1_valid)  // output wire valid
    );

    CEST_N_FIFO2 U_CEST_N_FIFO2 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(n2_din),      // input wire [11 : 0] din
        .wr_en(n2_wr_en),  // input wire wr_en
        .rd_en(n2_rd_en),  // input wire rd_en
        .dout(n2_dout),    // output wire [11 : 0] dout
        .full(n2_full),    // output wire full
        .empty(n2_empty),  // output wire empty
        .valid(n2_valid)  // output wire valid
    );

    CEST_N_FIFO3 U_CEST_N_FIFO3 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(n3_din),      // input wire [11 : 0] din
        .wr_en(n3_wr_en),  // input wire wr_en
        .rd_en(n3_rd_en),  // input wire rd_en
        .dout(n3_dout),    // output wire [11 : 0] dout
        .full(n3_full),    // output wire full
        .empty(n3_empty),  // output wire empty
        .valid(n3_valid)  // output wire valid
    );

    CEST_N_FIFO4 U_CEST_N_FIFO4 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(n4_din),      // input wire [11 : 0] din
        .wr_en(n4_wr_en),  // input wire wr_en
        .rd_en(n4_rd_en),  // input wire rd_en
        .dout(n4_dout),    // output wire [11 : 0] dout
        .full(n4_full),    // output wire full
        .empty(n4_empty),  // output wire empty
        .valid(n4_valid)  // output wire valid
    );


endmodule