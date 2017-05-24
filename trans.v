//% @file trans.v
//% @brief Implementation file of Transmitter(TRANS) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-25

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Transmitter(TRANS) is the top module.
//% 
//% @note frequency: pld_clk = sig_clk_c = 3*sig_clk_g
//% @todo payload mac --> channel encode
module TRANS (        
    input          new_frame,       //% new frame signal, reset some logic within TRANS module
                                    //% start to transmitter a new frame
    // for signal
    input          sig_clk_g,       //% clock to generate original signal bits
    input          sig_clk_c,       //% clock to channel encode signal bits
    input          sig_rst,         //% reset signal synchronized to sig_clk_g
    input  [15:0]  sig_di_len,      //% MAC frame lengths
    input  [3 :0]  sig_di_type,     //% MAC frame type
    input          sig_di_vld,      //% MAC frame data valid

    // for payload
    input          pld_clk,         //% clock for payload
    input          pld_rst,         //% reset signal synchronized to pld_clk

    output  signed  [11:0]  do_re,  //% output of transmitter, real part
    output  signed  [11:0]  do_im,  //% output of transmitter, image part
    output                  do_vld
    );

//==============================================================================
// wires

    //--------------------------------------------------------------------------
    // OBG --> CENC
    wire                  OBGCENC_signal_data;
    wire          [5:0]   OBGCENC_signal_data_init;
    wire                  OBGCENC_signal_data_vld;
    // for paylaod
    wire                  OBGCENC_payload_data;
    wire                  OBGCENC_payload_data_vld;
	 
    // wire                  OBGCENC_pld_rd_en;

    //--------------------------------------------------------------------------
    // CENC --> MOD
    wire                  CENCMOD_signal_data;
    wire                  CENCMOD_signal_data_vld;
    wire                  CENCMOD_pld_data;
    wire                  CENCMOD_pld_data_vld;

    //--------------------------------------------------------------------------
    // CENC --> DCU, IFFT
    wire    [3:0]         CENCDCU_sym_num;

    //--------------------------------------------------------------------------
    // MOD --> DCU
    wire  signed  [11:0]  MODDCU_signal_data_re;
    wire  signed  [11:0]  MODDCU_signal_data_im;
    wire                  MODDCU_signal_data_vld;

    wire  signed  [11:0]  MODDCU_payload_data_re;
    wire  signed  [11:0]  MODDCU_payload_data_im;
    wire                  MODDCU_payload_sym_end;
    wire                  MODDCU_payload_data_vld;

    //--------------------------------------------------------------------------
    // DCU --> IFFT_CP
    wire  signed  [11:0]  DCUIFFT_data_re;
    wire  signed  [11:0]  DCUIFFT_data_im;
    wire                  DCUIFFT_data_last;
    wire                  DCUIFFT_data_vld;

    //--------------------------------------------------------------------------
    // IFFT_CP --> PFU
    wire  signed  [11:0]  IFFTPFU_data_re;
    wire  signed  [11:0]  IFFTPFU_data_im;
    wire                  IFFTPFU_data_vld;

    //---------------------------------------------------------------------------
    // PFU --> TXOUT
    wire  signed  [11:0]  PFUOUT_data_re;
    wire  signed  [11:0]  PFUOUT_data_im;
    wire                  PFUOUT_data_vld;
	
//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // instantiate sub-module

    OBG U_OBG (
        // for signal segment
        .ssg_clk(sig_clk_g),
        .ssg_rst(sig_rst),
        .ssg_di_len(sig_di_len),
        .ssg_di_type(sig_di_type),
        .ssg_di_vld(sig_di_vld),

        .ssg_do(OBGCENC_signal_data),
        .ssg_do_init(OBGCENC_signal_data_init),
        .ssg_do_vld(OBGCENC_signal_data_vld),

        // for payload segment
        .new_frame(new_frame),
        .pld_clk(pld_clk),
        .pld_rst(pld_rst),
        .pld_do(OBGCENC_payload_data),
        .pld_do_vld(OBGCENC_payload_data_vld)

        // .pld_rd_en(OBGCENC_pld_rd_en)
    );

    CENC U_CENC (
        // for signal segment
        .sce_clk_i(sig_clk_g),
        .sce_rst(sig_rst),
        .sce_di(OBGCENC_signal_data),
        .sce_di_init(OBGCENC_signal_data_init),
        .sce_di_vld(OBGCENC_signal_data_vld),

        .sce_clk_o(sig_clk_c),
        .sce_do(CENCMOD_signal_data),
        .sce_do_vld(CENCMOD_signal_data_vld),

        // for payload segment
        .pld_clk(pld_clk),
        .pld_rst(pld_rst),
        .pld_di(OBGCENC_payload_data),
        .pld_di_vld(OBGCENC_payload_data_vld),
        .pld_do(CENCMOD_pld_data),
        .pld_do_vld(CENCMOD_pld_data_vld),
        .pld_do_sym_num(CENCDCU_sym_num)

        // .pld_clk(pld_clk),
        // .pld_rst(pld_rst),
        // .pld_rd_en(OBGCENC_pld_rd_en),
        // .pld_do(CENCMOD_pld_data),
        // .pld_do_vld(CENCMOD_pld_data_vld),
        // .pld_do_sym_num(CENCDCU_sym_num)
    );

    MOD U_MOD (
        // for signal segment
        .signal_clk(sig_clk_c),
        .signal_rst(sig_rst),
        .signal_di(CENCMOD_signal_data),
        .signal_di_vld(CENCMOD_signal_data_vld),

        .signal_do_re(MODDCU_signal_data_re),
        .signal_do_im(MODDCU_signal_data_im),
        .signal_do_vld(MODDCU_signal_data_vld),

        // for payload segment
        .payload_clk(pld_clk),
        .payload_rst(pld_rst),
        .payload_di(CENCMOD_pld_data),
        .payload_di_vld(CENCMOD_pld_data_vld),

        .payload_do_re(MODDCU_payload_data_re),
        .payload_do_im(MODDCU_payload_data_im),
        .payload_do_sym_end(MODDCU_payload_sym_end),
        .payload_do_vld(MODDCU_payload_data_vld)
    );

    DCU U_DCU (
        .new_frame(new_frame),

        // for sginal segment input
        .signal_clk(sig_clk_c),
        .signal_di_re(MODDCU_signal_data_re),
        .signal_di_im(MODDCU_signal_data_im),
        .signal_di_vld(MODDCU_signal_data_vld),

        // for payload segment input
        .payload_di_num(CENCDCU_sym_num),
        .payload_clk(pld_clk),
        .payload_di_re(MODDCU_payload_data_re),
        .payload_di_im(MODDCU_payload_data_im),
        .payload_di_sym_end(MODDCU_payload_sym_end),
        .payload_di_vld(MODDCU_payload_data_vld),

        // output
        .clk_o(pld_clk),
        .do_re(DCUIFFT_data_re),
        .do_im(DCUIFFT_data_im),
        .do_last(DCUIFFT_data_last),
        .do_vld(DCUIFFT_data_vld)
    );

    IFFT_CP U_IFFT_CP (
        .new_frame(new_frame),
        
        // input
        .clk(pld_clk),
        .di_sym_num(CENCDCU_sym_num),
        .di_re(DCUIFFT_data_re),
        .di_im(DCUIFFT_data_im),
        .di_last(DCUIFFT_data_last),
        .di_vld(DCUIFFT_data_vld),

        // output
        .do_re(IFFTPFU_data_re),
        .do_im(IFFTPFU_data_im),
        .do_vld(IFFTPFU_data_vld)
    );

    PFU U_FPU (
        .clk(pld_clk),
        .di_re(IFFTPFU_data_re),
        .di_im(IFFTPFU_data_im),
        .di_vld(IFFTPFU_data_vld),

        .do_re(PFUOUT_data_re),
        .do_im(PFUOUT_data_im),
        .do_vld(PFUOUT_data_vld)
    );

    TXOUT U_TXOUT (
        .new_frame(new_frame),
        .rst(pld_rst),
        // input
        .clk(pld_clk),
        .di_re(PFUOUT_data_re),
        .di_im(PFUOUT_data_im),
        .di_vld(PFUOUT_data_vld),

        // output
        .do_re(do_re),
        .do_im(do_im),
        .do_vld(do_vld)
    );

endmodule
