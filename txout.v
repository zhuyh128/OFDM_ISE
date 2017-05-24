//% @file txout.v
//% @brief Implementation file of Transmitter Output(TXOUT) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-27

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Transmitter Output(TXOUT) finish the output of final samples.
//% 
//% @note the ROM & RAM in this module use the same one clock
module TXOUT (
    input                        clk,           //% working
    input                        new_frame,     //% start flag of a new frame data
                                                //% work as reset signal
    input                        rst,           //% reset active high
    input        signed  [11:0]  di_re,         //% input data_re
    input        signed  [11:0]  di_im,         //% input data_im
    input                        di_vld,        //% input data valid

    output  reg  signed  [11:0]  do_re,         //% output data_re
    output  reg  signed  [11:0]  do_im,         //% output data_im
    output  reg                  do_vld         //% output data valid
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // write the input signal & payload segment into RAM

    wire  reset = rst || new_frame;

    reg          we;        //% write enable
    //% generate the write enable
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            we <= 0;
        end
        else begin
            we <= di_vld;
        end
    end

    reg  [12:0]  wr_addr;   //% write address
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            wr_addr <= 13'b1_1111_1111_1111;
        end
        else begin
            if (di_vld) begin
                wr_addr <= wr_addr + 1;
            end
            else begin
                wr_addr <= 13'b1_1111_1111_1111;
            end
        end
    end

    reg  signed  [11:0]  wr_dat_re;     //% real part data into RAM
    //% align the wr_dat_re and we
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            wr_dat_re <= 0;
        end
        else begin
            wr_dat_re <= di_re;
        end
    end

    reg  signed  [11:0]  wr_dat_im;     //% image part data into RAM
    //% align the wr_dat_im and we
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            wr_dat_im <= 0;
        end
        else begin
            wr_dat_im <= di_im;
        end
    end

    //--------------------------------------------------------------------------
    // read out preamble segment

    localparam   PRBG_ADDR_MAX = `N * `PRB_NUM - 1;

    reg          preamble_en_pre;    //% preamble ROM enable flag
    //% enable the  preamble ROM when input signal& payload data is valid
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            preamble_en_pre <= 0;
        end
        else begin
            if (di_vld) begin
                preamble_en_pre <= 1;
            end
            else if (preamble_addr == PRBG_ADDR_MAX) begin
                preamble_en_pre <= 0;
            end
        end
    end

    reg         preamble_en_pre_r1;
    reg         preamble_en_pre_r2;
    wire        preamble_en;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            preamble_en_pre_r1 <= 0;
            preamble_en_pre_r2 <= 0;
        end
        else begin
            preamble_en_pre_r1 <= preamble_en_pre;
            preamble_en_pre_r2 <= preamble_en_pre_r1;
        end
    end

    assign preamble_en = preamble_en_pre || preamble_en_pre_r2;

    reg  [11:0]  preamble_addr; //% preamble reading address
    //% generate the preamble ROM reading address
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            preamble_addr <= 0;
        end
        else begin
            if (preamble_en) begin
                preamble_addr <= preamble_addr + 1;
            end
            else begin
                preamble_addr <= 0;
            end
        end
    end

    wire  signed  [11:0]  preamble_re;
    wire  signed  [11:0]  preamble_im;

    //--------------------------------------------------------------------------
    // read out the signal & payload segment

    localparam  SIGPLD_RD_ADDR_MAX = (`N + `CP_LEN) * `MAX_NUM;
    reg                 sigpld_rd_en;
    reg     [12:0]      sigpld_rd_addr;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            sigpld_rd_en <= 0;
        end
        else begin
            if (preamble_addr == PRBG_ADDR_MAX) begin   // RAM read latency = 2
                sigpld_rd_en <= 1;
            end
            else if (sigpld_rd_addr == SIGPLD_RD_ADDR_MAX) begin
                sigpld_rd_en <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            sigpld_rd_addr <= 0;
        end
        else begin
            if (sigpld_rd_en) begin
                sigpld_rd_addr <= sigpld_rd_addr + 1;
            end
            else begin
                sigpld_rd_addr <= 0;
            end
        end
    end

    wire  signed  [11:0]  sigpld_re;
    wire  signed  [11:0]  sigpld_im;


    //--------------------------------------------------------------------------
    // final output

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            if (preamble_en) begin
                do_re <= preamble_re;
                do_im <= preamble_im;
            end
            else if (sigpld_rd_en) begin
                do_re <= sigpld_re;
                do_im <= sigpld_im;
            end
            else begin
                do_re <= 0;
                do_im <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // reset
            do_vld <= 0;
        end
        else begin
            do_vld <= preamble_en || sigpld_rd_en;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the IP core

    PRBG_RE_ROM U_PRBG_RE_ROM (
        .clka(clk),    // input wire clka
        .ena(preamble_en),      // input wire ena
        .addra(preamble_addr),  // input wire [11 : 0] addra
        .douta(preamble_re)  // output wire [11 : 0] douta
    );

    PRBG_IM_ROM U_PRBG_IM_ROM (
        .clka(clk),    // input wire clka
        .ena(preamble_en),      // input wire ena
        .addra(preamble_addr),  // input wire [11 : 0] addra
        .douta(preamble_im)  // output wire [11 : 0] douta
    );

    SIGPLD_RE_RAM U_SIGPLD_RE_RAM (
        .clka(clk),    // input wire clka
        .wea(we),      // input wire [0 : 0] wea
        .addra(wr_addr),  // input wire [12 : 0] addra
        .dina(wr_dat_re),    // input wire [11 : 0] dina

        .clkb(clk),    // input wire clkb
        .addrb(sigpld_rd_addr),  // input wire [12 : 0] addrb
        .doutb(sigpld_re)  // output wire [11 : 0] doutb
    );

    SIGPLD_IM_RAM U_SIGPLD_IM_RAM (
        .clka(clk),    // input wire clka
        .wea(we),      // input wire [0 : 0] wea
        .addra(wr_addr),  // input wire [12 : 0] addra
        .dina(wr_dat_im),    // input wire [11 : 0] dina

        .clkb(clk),    // input wire clkb
        .addrb(sigpld_rd_addr),  // input wire [12 : 0] addrb
        .doutb(sigpld_im)  // output wire [11 : 0] doutb
    );

endmodule
