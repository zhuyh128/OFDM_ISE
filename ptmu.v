//% @file ptmu.v
//% @brief Implementation file of Payload Tone Map Unit(PTMU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-25

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Payload Tone Map Unit(PTMU) finish the tone mapping for payload segment.
//% 
//% **Timing:**
//%
//% 1. input continous channel encoded data
//% 2. group every 4 bits into a result, output a result data every 4 clock
//%    period
//%
//% @warning This module only support **QPSK** & **16QAM**
//%          Need to extend the output width for higher modulation. 
//% @note    BAT is removed for simplify the design, because all sub-carriers
//%          use the same modulation type.
//% @note    {do}'s high part is valid, 
//%          for example: in 16QAM mode do = 1010110, then the most high 4 bits
//%          are valid: 1010
//% @note    Move the padding work into a previous module to simplify the design
module PTMU (
    input               clk,         //% working clock
    input               rst,         //% asynchronous reset
    input               di,          //% input data to be tone mapped
    input               di_vld,      //% input data valid

    output  reg  [3:0]  do,          //% tone mapped data output
    output  reg         do_sym_end,  //% end flag of each OFDM symbol
    output  reg         do_vld       //% output data valid
    );

//==============================================================================
// Main Body of Code

    `ifdef      QPSK
        localparam  BITS_MAX = 1;   //% QPSK using 2 bits
    `elsif      16QAM
        localparam  BITS_MAX = 3;   //% 16QAM using 4 bits
    `else
        localparam  BITS_MAX = 3;   //% default modulation is 16QAM
    `endif

    //--------------------------------------------------------------------------
    // tone mapping

    `ifdef      QPSK
        reg     [1:0]   bits_cnt;   //% QPSK counter used to group data
    `elsif      16QAM
        reg     [1:0]   bits_cnt;   //% 16QAM counter used to group data
    `else
        reg     [1:0]   bits_cnt;   //% default 16QAM counter
    `endif

    //% counter module (BIT_MAX+1)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            bits_cnt <= 0;
        end
        else begin
            if (di_vld) begin
                if (bits_cnt == BITS_MAX) 
                    bits_cnt <= 0;
                else
                    bits_cnt <= bits_cnt + 1;
            end
            else begin
                bits_cnt <= 0;
            end
        end
    end

    //% tone mapping
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            do <= 4'bx;
            `ifdef      QPSK
                case (bits_cnt)         // valid output is do[3:2]
                    2'b0: do <= {di, 3'b0};
                    2'b1: do <= {di, do[3:1]};    // valid output
                endcase
            `elsif      16QAM
                case (bits_cnt)         // valid output is do[3:0]
                    2'd0:       do <= {di, 3'b0};
                    2'd1:       do <= {di, 3'b0};
                    2'd2:       do <= {di, do[3:1]};
                    2'd3:       do <= {di, do[3:1]}; // valid output
                endcase
            `else                       // default modulation is 16QAM
                case (bits_cnt)         // valid output is do[3:0]
                    2'd0:       do <= {di, 3'b0};
                    2'd1:       do <= {di, do[3:1]};
                    2'd2:       do <= {di, do[3:1]};
                    2'd3:       do <= {di, do[3:1]}; // valid output
                endcase
            `endif
        end
    end

    //% align the do & do_vld
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            if (bits_cnt == BITS_MAX)
                do_vld <= 1;
            else
                do_vld <= 0;
        end
    end

    //--------------------------------------------------------------------------
    // get the end of each OFDM symbol to reset LSFR
    // in constellation scramble

    localparam      SC_MAX = `N - `SPACE_NUM;    //% max sub-carrier index = N-1
    reg     [8:0]   sc_cnt;                        //% sub-carrier counter
    //% count sub-carriers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sc_cnt <= 0;
        end
        else begin
            if (sc_cnt == SC_MAX) begin
                sc_cnt <= 0;
            end
            else begin
                if (bits_cnt == BITS_MAX) sc_cnt <= sc_cnt + 1;
            end
        end
    end

    //% find the end of each OFDM symbol
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_sym_end <= 0;
        end
        else begin
            if (sc_cnt == (SC_MAX-1) && bits_cnt == BITS_MAX)
                do_sym_end <= 1;
            else
                do_sym_end <= 0;
        end
    end
endmodule