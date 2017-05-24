//% @file fpce.v
//% @brief Implementation file of Fake Payload Channel Encoder(fpce) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-04

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% fake LDPC encoder for test, to be deleted
//% 
//% @noteread encoded data from ROM instead of real encoder for test!
module FPCE (
    input          clk, 
    input          rst,
    input          rd_en,
    output  reg    do,
    output  reg    do_vld
    );

//==============================================================================
// Main Body of Code

    //------------------------------------------------
    // detect posedge of rd_en
    reg         rd_en_r1;
    reg         rd_en_r2;
    wire        rd_en_posedge;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en_r1 <= 0;
            rd_en_r2 <= 0;
        end
        else begin
            rd_en_r1 <= rd_en;
            rd_en_r2 <= rd_en_r1;
        end
    end

    assign rd_en_posedge = rd_en_r1 & (!rd_en_r2);


    //----------------------------------------------
    // generate address of ROM
    reg          addr_en;
    reg  [13:0]  addr;
    wire         dout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addr_en <= 0;
        end
        else begin
            if (rd_en_posedge) begin
                addr_en <= 1;
            end
            else if (addr == 14'd8639) begin
                addr_en <= 0;
            end
            else begin
                addr_en <= addr_en;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addr <= 14'd0;
        end
        else begin
            if (addr_en) begin
                addr <= addr + 1;
            end
            else begin
                addr <= 14'd0;
            end
        end
    end

    //----------------------------------------------
    // generate output

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            do <= dout;
        end
    end

    reg     dout_vld_pre;
    reg     dout_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_vld_pre <= 0;
            dout_vld <= 0;
            do_vld <= 0;
        end
        else begin
            dout_vld_pre <= addr_en;
            dout_vld <= dout_vld_pre;
            do_vld <= dout_vld;
        end
    end

    //----------------------------------------------
    // 
    FPCE_ROM U_FPCE_ROM (
        .clka(clk),    // input wire clka
        .addra(addr),  // input wire [13 : 0] addra
        .douta(dout)  // output wire [0 : 0] douta
    );

endmodule