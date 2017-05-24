//% @file decp.v
//% @brief Implementation file of De-Cyclic Prefix(DECP) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-11

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% De-Cyclic Prefix(DECP) remove the cyclic prefix for signal & payload segment
//% using a FIFO.
//% 
//% **Timing**
//% 
//% 1. save the input data into FIFO, except the CP part
//% 2. when finished all data, start to read out
//% 
//% @note the FIFO depth = 8192, so the symbol number < floor{8192/(512+32)} = 15
//%       (the upstream logic require the number of signal & payload <= 7)
module DECP (
    input                        clk,       //% working clock
    input                        rst,       //% synchronous reset, active high
    input        signed  [11:0]  di_re,     //% input data to be decped, real part
    input        signed  [11:0]  di_im,     //% input data to be decped, image part
    input                        di_vld,    //% input data valid flag
    output  reg  signed  [11:0]  do_re,     //% decped output data, real part
    output  reg  signed  [11:0]  do_im,     //% decped output data, image part
    output  reg                  do_vld     //% output data valid
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // write data into FIFO

    //% upstream logic decide the symbol number <= 7
    localparam      WR_CNT_MAX = (`N + `CP_LEN) * 7;
    reg     [12:0]  wr_cnt;     //% counter use to calculate all input data samples
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX) begin
                wr_cnt <= WR_CNT_MAX;
            end
            else if (di_vld) begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end

    localparam      CP_CNT_MAX = `CP_LEN;
    reg     [5:0]   cp_cnt;         //% counter used to count cyclic preifx
    localparam      SYMBOL_CNT_MAX = `N;
    reg     [9:0]   symbol_cnt;     //% counter used to count N samples

    //% count every cyclic preifx
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cp_cnt <= 0;
        end
        else begin
            if (symbol_cnt == SYMBOL_CNT_MAX-1) begin
                cp_cnt <= 0;
            end
            else if (cp_cnt == CP_CNT_MAX) begin
                cp_cnt <= CP_CNT_MAX;
            end
            else if (di_vld) begin
                cp_cnt <= cp_cnt + 1;
            end
        end
    end

    //% count the N samples to be saved into FIFO
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            symbol_cnt <= 0;
        end
        else begin
            if (cp_cnt == CP_CNT_MAX - 1) begin
                symbol_cnt <= 0;
            end
            else if (symbol_cnt == SYMBOL_CNT_MAX) begin
            symbol_cnt <= SYMBOL_CNT_MAX;
            end
            else if (cp_cnt ==CP_CNT_MAX && di_vld) begin
                symbol_cnt <= symbol_cnt + 1;
            end
        end
    end

    wire            full;       //% FIFO full flag
    reg     [23:0]  din;        //% FIFO input data
    reg             wr_en;      //% FIFO write enable

    //% get the data into FIFO
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din <= 0;
        end
        else begin
            din <= {di_im, di_re};
        end
    end

    //% when input data is the valid N samples, enable the FIFO writen 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
        end
        else begin
            if (cp_cnt == CP_CNT_MAX) begin
                wr_en <= 1;
            end
            else begin
                wr_en <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // read out data from FIFO

    wire            empty;      //% FIFO empty flag
    wire  [23:0]    dout;       //% FIFO output
    wire            valid;      //% FIFO output valid flag
    reg             rd_en;      //% FIFO read enable

    //% when all input data is saved, start to read out
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (wr_cnt >= WR_CNT_MAX && !empty) begin
                rd_en <= 1;
            end
        end
    end

    //% get the final output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
            do_re  <= 0;
            do_im  <= 0;
        end
        else begin
            do_vld <= valid;
            do_re  <= dout[11: 0];
            do_im  <= dout[23:12];
        end
    end

    
    //--------------------------------------------------------------------------
    // instantiate the FIFO IP core

    DECP_FIFO U_DECP_FIFO (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(din),      // input wire [23 : 0] din
        .wr_en(wr_en),  // input wire wr_en
        .rd_en(rd_en),  // input wire rd_en
        .dout(dout),    // output wire [23 : 0] dout
        .full(full),    // output wire full
        .empty(empty),  // output wire empty
        .valid(valid)  // output wire valid
    );

endmodule