//% @file dsep.v
//% @brief Implementation file of Data Separation(DSEP) module.
//% 
//% @author  Qian Gu
//% @modified by Xu Xunzhi, to fit multi-frame,2016-10-26 
//% @version 1.0
//% @date 2015-06-10

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Data Separation(DSEP) finish the separation of preamble and signal&payload.
//% 
//% **Timing**
//% 
//% 1. save the compensated data into a FIFO(RAM need additional address signal)
//% 2. when get the symbol synchronization point, start to read out the data
//% 3. output the data into 2 stream
//% 
//% @note using a FSM, wait all input data in saved, then read out(beacuse input 
//%       data rate < read rate, incase of read error)
//% @note The total number of input valid data is 9536 according to CFOC module,
//%       input data：
//%       
//%       7.5 preamble + 1 signal + 5 payload + invalid data
//%       
//%      （512-max_indx + 7*512 + (512+32)*6 + delta = 7360 + delta)
//%       
//%       this module save the first 8192 samples(>7360), so the FIFO depth is enough.
module DSEP (
    input                        clk,               //% working clock
    input                        rst,               //% sychronous reset, active high
    input        signed  [11:0]  di_re,             //% input compensated data, real part
    input        signed  [11:0]  di_im,             //% input compensated data, image part
    input                        di_vld,            //% input data valid flag
    input                [9 :0]  max_indx,          //% symbol synchronization result
    input                        max_indx_vld,      //% symbol synchronization result valid flag
    output  reg  signed  [11:0]  do_preamble_re,    //% output preamble symbol, real part
    output  reg  signed  [11:0]  do_preamble_im,    //% output preamble symbol, image part
    output  reg                  do_preamble_vld,   //% output preamble symbol valid flag
    output  reg  signed  [11:0]  do_sigpld_re,      //% output signal & payload, real part
    output  reg  signed  [11:0]  do_sigpld_im,      //% output signal & payload, image part
    output  reg                  do_sigpld_vld      //% output signal & payload valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // using a FSM controll the whole process

    localparam      INPUT  = 2'b01,
                    OUTPUT = 2'b10;

    reg     [1:0]   CS;
    reg     [1:0]   NS;

    //% FSM-1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            CS <= INPUT;
        end
        else begin
            CS <= NS;
        end
    end

    //% FSM-2
    always @* begin
        NS = 2'bx;
        case (CS)
            INPUT: begin
                if (rst) begin
                    NS = INPUT;
                end
                else if (wr_cnt == WR_CNT_MAX) begin
                    NS = OUTPUT;
                end
                else begin
                    NS = INPUT;
                end
            end
            OUTPUT: begin
                if (rst) begin
                    NS = INPUT;
                end
                else begin
                    // NS = OUTPUT;
                    if (out_finish) begin
                        NS = INPUT;
                    end
                    else begin
                        NS = OUTPUT;
                    end
                end
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // save input data into FIFO
    
    localparam   WR_CNT_MAX = 8192 - 1;     //% FIFO depth = 8192
    reg  [12:0]  wr_cnt;

    //% FSM-3: wr_cnt
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 0;
        end
        else begin
            case (NS)
                INPUT: begin
                    if (wr_cnt == WR_CNT_MAX) begin
                        wr_cnt <= WR_CNT_MAX;
                    end
                    else begin
                        if (di_vld) begin
                            wr_cnt <= wr_cnt + 1;
                        end
                        else begin
                            wr_cnt <= wr_cnt;
                        end
                    end
                    // else if (di_vld) begin
                    //     wr_cnt <= wr_cnt + 1;
                    // end
                end
                OUTPUT: begin
                    wr_cnt <= 0;
                end
            endcase
        end
    end

    reg  [23:0]  din;
    reg          wr_en;
    wire         full;

    //% FSM-3: din
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din <= 0;
        end
        else begin
            // din <= 0;
            case (NS)
                INPUT: begin
                    din <= {di_im, di_re};
                end
                OUTPUT: begin
                    // do nothing
                    din <= 0;
                end
            endcase
        end
    end

    //% FSM-3: wr_en
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
        end
        else begin
            // wr_en <= 0;
            case (NS)
                INPUT: begin
                    if (wr_cnt < WR_CNT_MAX && di_vld && !full) begin
                        wr_en <= 1;
                    end
                    else begin
                        wr_en <= 0;
                    end
                end
                OUTPUT: begin
                    // do nothing
                    wr_en <= 0;
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // read out data

    wire          empty;
    reg           rd_en;
    wire          valid;
    wire  [23:0]  dout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            // rd_en <= 0;
            case (NS)
                INPUT: begin
                    // do nothing
                    rd_en <= 0;
                end
                OUTPUT: begin
                    if (!empty) begin
                        rd_en <= 1;
                    end
                    else begin
                        rd_en <= 0;
                    end
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // get preamble segment: the 3rd~8th symbol

    localparam   NUM_PREAMBLE = `N * (`PRB_NUM - 1);
    reg  [12:0]  preamble_cnt;  //% counter used to divide preamble segment

    reg  [9:0]   max_indx_r;    //% save the valid max_indx, fix the error of 
                                //% ssync module(-1)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            max_indx_r <= 0;
        end
        else begin
            if (max_indx_vld) begin
                max_indx_r <= max_indx - 1;
            end
        end
    end

    //% FSM-3: preamble_cnt
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            preamble_cnt <= 0;
        end
        else begin
            case (NS)
                INPUT: begin
                    // do nothing
                    preamble_cnt <= 0;
                end
                OUTPUT: begin
                    if (preamble_cnt == max_indx_r + NUM_PREAMBLE) begin
                        preamble_cnt <= max_indx_r + NUM_PREAMBLE;
                    end
                    else if (valid) begin
                        preamble_cnt <= preamble_cnt + 1;
                    end
                end
            endcase
        end
    end

    //% FSM-3: do_preamble_re/im
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_preamble_re <= 0;
            do_preamble_im <= 0;
        end
        else begin
            // do_preamble_re <= 0;
            // do_preamble_im <= 0;
            case (NS)
                INPUT: begin
                    // do nothing
                    do_preamble_re <= 0;
                    do_preamble_im <= 0;
                end
                OUTPUT: begin
                    do_preamble_re <= dout[11: 0];
                    do_preamble_im <= dout[23:12];
                end
            endcase
        end
    end

    //% FSM-3: do_preamble_vld
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_preamble_vld <= 0;
        end
        else begin
            // do_preamble_vld <= 0;
            case (NS)
                INPUT: begin
                    // do nothing
                    do_preamble_vld <= 0;
                end
                OUTPUT: begin
                    // select the 3rd~8th preamble symbol
                    if (preamble_cnt >= max_indx_r + `N &&
                        preamble_cnt < max_indx_r + NUM_PREAMBLE) begin
                        do_preamble_vld <= 1;
                    end
                    else begin
                        do_preamble_vld <= 0;
                    end
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // get signal & payload segment

    //% the FIFO depth = 8192, except preamble x + 512*7 (x=114 in sim),
    //% for signal & payload, number of samples < 8192 - x - 512*7, no
    //% more than 7 symbols.
    localparam   SIGPLD_CNT_MAX = (`N + `CP_LEN) * (`MAX_NUM - 3);
    reg  [12:0]  sigpld_cnt;    //% counter used to divide signal & payload segment

    //% FSM-3: sigpld_cnt
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sigpld_cnt <= 0;
        end
        else begin
            case (NS)
                INPUT: begin
                    // do nothing
                    sigpld_cnt <= 0;
                end
                OUTPUT: begin
                    if (sigpld_cnt == SIGPLD_CNT_MAX) begin
                        sigpld_cnt <= SIGPLD_CNT_MAX;
                    end
                    else if (preamble_cnt >= max_indx_r + NUM_PREAMBLE &&
                             rd_en) begin
                        sigpld_cnt <= sigpld_cnt + 1;
                    end
                end
            endcase
        end
    end

    //% FSM-3: do_sigpld_re/im
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_sigpld_re <= 0;
            do_sigpld_im <= 0;
        end
        else begin
            do_sigpld_re <= 0;
            do_sigpld_im <= 0;
            case (NS)
                INPUT: begin
                    // do nothing
                    // do_sigpld_re <= 0;
                    // do_sigpld_im <= 0;
                end
                OUTPUT: begin
                    do_sigpld_re <= dout[11: 0];
                    do_sigpld_im <= dout[23:12];
                end
            endcase
        end
    end

    //% FSM-3: do_sigpld_vld    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_sigpld_vld <= 0;
        end
        else begin
            // do_sigpld_vld <= 0;
            case (NS)
                INPUT: begin
                    // do nothing
                    do_sigpld_vld <= 0;
                end
                OUTPUT: begin
                    if (preamble_cnt >= max_indx_r + NUM_PREAMBLE &&
                        sigpld_cnt < SIGPLD_CNT_MAX) begin
                        do_sigpld_vld <= 1;
                    end
                    else begin
                        do_sigpld_vld <= 0;
                    end
                end
            endcase
        end
    end

    // current frame finish
    reg out_finish;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_finish <= 0;
        end
        else begin
            case(NS)
                INPUT: begin
                    out_finish <= 0;
                end
                OUTPUT:begin
                    if (preamble_cnt >= max_indx_r + NUM_PREAMBLE &&
                        sigpld_cnt == SIGPLD_CNT_MAX) begin
                        out_finish <= 1;
                    end
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the FIFO core

    DSEP_FIFO U_DSEP_FIFO (
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