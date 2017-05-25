//% @file sce.v
//% @brief Implementation file of Signal Channel Encoder(SCE) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-07

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Signal Channel Encoder(SCE) module finish the tail-biting convolution encode
//% for signal segment data, and repeat the result 10 times to get 960 samples.
//% 
//% @note clk_i & clk_o should have the same phase, and Fclk_o = 3*Fclk_i ! 
//% 
module SCE (
	 input					done_rst,
    input               clk_i,      //% clock for input data
    input               clk_o,      //% clock for output data
    input               rst,        //% asynchronous reset to clk_i, active high
    input               di,         //% signal data input to be encoded
    input    [5 : 0]    di_init,    //% data input, initialize the LSR
    input               di_vld,     //% data input valid

    output  reg         do,         //% channel encoded signal data output
    output  reg         do_vld      //% data output valid
    ); 

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // initialize 

    reg     dat;       //% local tmp for di
    //% reg the input data for one clock to initilize the LSR
    always @(posedge clk_i or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dat <= 0;
        end
        else begin
            dat <= di;
        end
    end

    reg     dat_vld;    //% local tmp data valid
    //% align the dat & dat_vld
    always @(posedge clk_i or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dat_vld <= 0;
        end
        else begin
            dat_vld <= di_vld;
        end
    end

    reg     [`K-1 : 0]      LSR;    //% linear shift reg
    //% initilize & shift the LSR
    always @(posedge clk_i or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            LSR <= di_init;
        end
        else begin
            if (dat_vld) begin
                LSR <= {dat, LSR[5:1]};    // shift 1 reg once
            end
            else begin
                LSR <= di_init;
            end
        end
    end

    //--------------------------------------------------------------------------
    // encode

    localparam  ENC_DAT_WIDTH = 3;   //% (3, 1, 6) tail-biting, constraint = 6
    reg     [ENC_DAT_WIDTH-1 : 0]    enc_dat;   //% encoded data, 1 --> 3 bits
    //% tail-biting convolution encode
    always @(posedge clk_i or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            enc_dat <= 0;
        end
        else begin
            if (dat_vld) begin
                enc_dat[0] <= dat + LSR[4] + LSR[3] + LSR[1] + LSR[0];
                enc_dat[1] <= dat + LSR[5] + LSR[4] + LSR[3] + LSR[0];
                enc_dat[2] <= dat + LSR[5] + LSR[4] + LSR[2] + LSR[0];
            end
            else begin
                enc_dat <= 0;
            end
        end
    end
	 
    reg         enc_dat_vld;    //% encoded data valid flag
    //% align the enc_dat & enc_dat_vld
    always @(posedge clk_i or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            enc_dat_vld <= 0;
        end
        else begin
            enc_dat_vld <= dat_vld;
        end
    end

    //--------------------------------------------------------------------------
    // save the encoded data

    localparam  INDX_WIDTH    = 2;   //% index reg width
    localparam  MAX           = 2;   //% (3, 1, 6) tail-biting, max index = 2
    reg     [INDX_WIDTH-1 : 0]      indx;       //% output index
    //% generate the pre_do index
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            indx <= 0;
        end
        else begin
            if (enc_dat_vld) begin
                if (indx == MAX) indx <= 0;
                else             indx <= indx + 1;
            end
            else begin
                indx <= 0;
            end
        end
    end

    reg     pre_do;         //% one result of tail-biting encoder
    //% save the tmp result
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            pre_do <= 0;
        end
        else begin
            pre_do <= enc_dat[indx];
        end
    end

    reg     pre_do_vld;     //% pre_do valid flag
    //% align the pre_do & pre_do_ vld
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            pre_do_vld <= 0;
        end
        else begin
            pre_do_vld <= enc_dat_vld;
        end
    end

    //--------------------------------------------------------------------------
    // repeat the pre_do 10 times to get the final ouput

    reg  [6:0]  wr_addr;     //% index to save pre_do(96 bits)
    //% get the value of wr_addr
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            wr_addr <= 0;
        end
        else begin
            if (pre_do_vld) begin
                wr_addr <= wr_addr + 1;
            end
            else begin
                wr_addr <= 0;
            end
        end
    end

    reg     [95:0]  save_dat;   //% reg saving pre_do
    //% save pre_do
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            save_dat[wr_addr] <= 0;
        end
        else begin
            if (pre_do_vld) begin
                save_dat[wr_addr] <= pre_do;
            end
        end
    end

    //--------------------------------------------------------------------------
    // output the result
    
    reg     symbol_cnt_en;
    localparam  SYMBOL_CNT_MAX = 9;     //% repeat 10 times
    reg  [3:0]  symbol_cnt;             //% count repeat times
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            symbol_cnt_en <= 0;
        end
        else begin
            if (wr_addr > 0) begin
                symbol_cnt_en <= 1;
            end
            if (symbol_cnt > SYMBOL_CNT_MAX) begin
                symbol_cnt_en <= 0;
            end
        end
    end

    //% count the output times
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            symbol_cnt <= 0;
        end
        else begin
            if (symbol_cnt_en) begin
                if (rd_addr == 95) begin
                    symbol_cnt <= symbol_cnt + 1;
                end
            end
            else begin
                symbol_cnt <= 0;
            end
        end
    end

    reg     rd_en;      //% read enable flag
    localparam  RD_ADDR_MAX = 95;
    reg     [6:0]   rd_addr;     //% reading address
    //% get the read enable flag value
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (wr_addr > 0) begin
                rd_en <= 1;
            end
            if (symbol_cnt == SYMBOL_CNT_MAX && rd_addr == 95) begin
                rd_en <= 0;
            end
        end
    end

    //% get the reading address value
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rd_addr <= 0;
        end
        else begin
            if (rd_en > 0) begin
                if (rd_addr == RD_ADDR_MAX) begin
                    rd_addr <= 0;
                end
                else begin
                    rd_addr <= rd_addr + 1;
                end
            end
        end
    end

    //% ouptut do
    always @(posedge clk_o or posedge rst or posedge done_rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            do <= save_dat[rd_addr];
        end
    end

    //% align do & do_vld
    always @(posedge clk_o) begin
        do_vld <= rd_en;
    end

endmodule