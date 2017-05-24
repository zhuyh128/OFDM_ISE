//% @file scdm.v
//% @brief Implementation file of Signal Constellation De-Mapping(SCDM) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-25

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Signal Constellation De-Mapping(SCDM) finish the constellation de-mapping 
//% for signal segment. de-mapping rules:
//% I > 0, Q > 0, -> 00
//% I > 0, Q < 0, -> 01
//% I < 0, Q > 0, -> 10
//% I < 0, Q < 0, -> 11
module SCDM (
    input                  clk,     //% working clock
    input                  rst,     //% reset, active high
    input  signed  [11:0]  di_re,   //% input signal data to be de-mapped
    input  signed  [11:0]  di_im,   //% input signal data to be de-mapped
    input                  di_vld,  //% input data valid
    output                 do,      //% output signal data to be decoded
    output                 do_vld   //% output data valid
    );

//=============================================================================
// Main Body of Code

    reg  [1:0]  demapped_data;
    reg         demapped_data_vld;
    //% demap
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            demapped_data <= 2'b00;
        end
        else begin
            if (di_vld) begin
                if (di_re > 0)
                    demapped_data[1] <= 1'b0;
                else
                    demapped_data[1] <= 1'b1;
                if (di_im > 0)
                    demapped_data[0] <= 1'b0;
                else
                    demapped_data[0] <= 1'b1;
            end
            else begin
                demapped_data <= 2'b0;
            end
        end
    end

    reg  [8:0]  cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (di_vld) begin
                cnt <= cnt + 1;
            end
            else begin
                cnt <= 0;
            end
        end
    end
    //% input data index [16, 495] is valid
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            demapped_data_vld <= 0;
        end
        else begin
            if (cnt >= 9'd16 && cnt <= 10'd495) begin
                demapped_data_vld <= 1'b1;
            end
            else begin
                demapped_data_vld <= 1'b0;
            end
        end
    end

    //% write temp data into FIFO
    reg  [1:0]  din;
    reg         wr_en;
    wire        full;
    reg [6:0] write_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
            din   <= 0;
        end
        else begin
           if (!full) begin
                din <= demapped_data;
                wr_en <= demapped_data_vld;
            end 
            else begin
                din <= 0;
                wr_en <= 0;
            end
        end
    end

    reg     rd_en;
    wire    empty;
    wire    dout;
    wire    valid;
    //% read out tmp data from FIFO
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (!empty)  begin
                rd_en <= 1'b1;
            end
            else begin
                rd_en <= 1'b0;
            end
        end
    end

    MEAN U_MEAN (
        .clk(clk),
        .rst(rst),
        .di(dout),
        .di_vld(valid),
        .do(do),
        .do_vld(do_vld)
        );


    //--------------------------------------------------------------------------
    // instantiate the FIFO core
    
    //% FIFO to save temp demapped data
    SCDM_FIFO U_SCDM_FIFO (
        .rst(rst),        // input wire rst
        .wr_clk(clk),  // input wire wr_clk
        .rd_clk(clk),  // input wire rd_clk
        .din(din),        // input wire [1 : 0] din
        .wr_en(wr_en),    // input wire wr_en
        .rd_en(rd_en),    // input wire rd_en
        .dout(dout),      // output wire [0 : 0] dout
        .full(full),      // output wire full
        .empty(empty),    // output wire empty
        .valid(valid)    // output wire valid
    );


endmodule