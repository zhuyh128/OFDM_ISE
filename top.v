//% @file top.v
//% @brief Implementation file of Top(TOP) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-04

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Top module
//% 
//% @note current version is for test only, to be modified later.
//% @note the follow port are used for test,to be deleted! (debug_clk).
//
//% @note to match the port of AD9364, delete the port of start_butten, and
//% @note generate a start signal in the FMAC module.
//

module TOP (
    input           clk_in_p,
    input           clk_in_n,
    input           rst_In,
    // input           start_butten,
    // output  [11:0]  trans_do_re,
    // output  [11:0]  trans_do_im,
    // input   [11:0]  recv_di_re,
    // input   [11:0]  recv_di_im,
    (* KEEP = "TRUE" *)output          do_signal,
    (* KEEP = "TRUE" *)output          do_signal_vld,
    (* KEEP = "TRUE" *)output          do_payload,
    (* KEEP = "TRUE" *)output          do_payload_vld

    // for debug
    // output         debug_clk
    // end of debug
    );

//==============================================================================
// Main Body of Code
    
    //--------------------------------------------------------------------------
    // FMAC --> TRANS
    wire          FMAC2TRANS_new_frame;
    wire          FMAC2TRANS_frame_vld;
    wire  [15:0]  FMAC2TRANS_frame_len;
    wire  [03:0]  FMAC2TRANS_frame_type;

    //--------------------------------------------------------------------------
    // TRANS --> RECV
    // for debug 
    (* KEEP = "TRUE" *)wire  [11:0]  TRANSRECV_data_re;
    (* KEEP = "TRUE" *)wire  [11:0]  TRANSRECV_data_im;  

    //--------------------------------------------------------------------------
    // SCG_clock  --> TRANS, RECV
    wire          SYS_trans_clk_50MHz;
    wire          SYS_trans_clk_150MHz;
    wire          SYS_recv_clk_150MHz;
    wire          locked;

    //--------------------------------------------------------------------------
    // SRG  --> TRANS, RECV
    wire         SYS_RST_trans_sig;
    wire         SYS_RST_trans_pld;
    wire         SYS_RST_recv;

    // dcm ip core 
    SCG_clock U_DCM(
        // Clock in ports
        .clk_in200MHz_P(clk_in_p),    // IN 200MHz
        .clk_in200MHz_N(clk_in_n),    // IN 200MHz
        // Clock out ports
        .clk_out50MHz(SYS_trans_clk_50MHz),     // OUT 17MHz
        .clk_out150MHz_1(SYS_trans_clk_150MHz),     // OUT 51MHz
        .clk_out150MHz_2(SYS_recv_clk_150MHz),     // OUT 51MHz
        // Status and control signals
        .LOCKED(locked)    // OUT
    );   

    // --------------------------------------------------------------------
    // soft reset
    localparam  CNT_MAX = 170000;
    localparam  VALUE0 = 169000;

    integer cnt = 0;
    reg soft_rst_n;
    wire rst_I;

    always @(posedge SYS_trans_clk_50MHz or negedge locked) begin
        if (!locked) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (cnt == CNT_MAX) begin
                cnt <= 0;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    always @(posedge SYS_trans_clk_50MHz or negedge locked) begin
        if (!locked) begin
            // reset
            soft_rst_n <= 0;
        end
        else begin
            if ((cnt >= VALUE0) && (cnt < CNT_MAX)) begin
                soft_rst_n <= 1;
            end
            else begin
                soft_rst_n <= 0;
            end
        end
    end


    // wire [23:0] test_signal;

    assign rst_I = (rst_In & soft_rst_n);

    // ---------------------------------------------------------------

    SRG U_SRG (
        .clk_trans_sig(SYS_trans_clk_50MHz),
        .clk_trans_pld(SYS_trans_clk_150MHz),
        .clk_recv(SYS_recv_clk_150MHz),
        .rst_i(rst_I),
        .sys_rst_trans_sig(SYS_RST_trans_sig),
        .sys_rst_trans_pld(SYS_RST_trans_pld),
        .sys_rst_recv(SYS_RST_recv)
    );

    FMAC U_FMAC (
        .clk(SYS_trans_clk_50MHz),
        .rst(SYS_RST_trans_sig),
        //.start(start_butten),
        .new_frame(FMAC2TRANS_new_frame),
        .frame_vld(FMAC2TRANS_frame_vld),
        .frame_len(FMAC2TRANS_frame_len),
        .frame_type(FMAC2TRANS_frame_type)
    );

    TRANS U_TRANS (
        .new_frame(FMAC2TRANS_new_frame),      
        .sig_clk_g(SYS_trans_clk_50MHz),  
        .sig_clk_c(SYS_trans_clk_150MHz),  
        .sig_rst(SYS_RST_trans_sig),    
        .sig_di_len(FMAC2TRANS_frame_len), 
        .sig_di_type(FMAC2TRANS_frame_type),
        .sig_di_vld(FMAC2TRANS_frame_vld), 
        .pld_clk(SYS_trans_clk_150MHz),    
        .pld_rst(SYS_RST_trans_pld), 
        // .do_re(trans_do_re),
        // .do_im(trans_do_im),

        // for debug
        .do_re(TRANSRECV_data_re),
        .do_im(TRANSRECV_data_im),
        // end of debug
        .do_vld()   
    );

    //--------------------
    RECV U_RECV (
        .clk(SYS_recv_clk_150MHz),
        .rst(SYS_RST_recv),
        // .di_re(recv_di_re),
        // .di_im(recv_di_im),

        // for debug
        .di_re(TRANSRECV_data_re),
        .di_im(TRANSRECV_data_im),
        // .test_signal(test_signal),
        // end of debug

        .do_signal(do_signal),
        .do_signal_vld(do_signal_vld),
        .do_payload(do_payload),
        .do_payload_vld(do_payload_vld)
    );

    // for debug
    // assign debug_clk = SYS_recv_clk_150MHz;
    // end of debug

    // chipscope
    wire [35:0] CONTROL0;
    wire [3:0] TRIG0 = {
                         do_signal,
                         do_signal_vld,
                         do_payload,
                         do_payload_vld
                        };

/*    ilao U_ILA0 (
        .CONTROL(CONTROL0), // INOUT BUS [35:0]
        .CLK(SYS_recv_clk_150MHz), // IN
        .TRIG0(TRIG0) // IN BUS [3:0]
    );

    icon0 U_ICON0(
        .CONTROL0(CONTROL0) // INOUT BUS [35:0]
        );
*/
endmodule