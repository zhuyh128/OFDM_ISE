//% @file fftu.v
//% @brief Implementation file of FFT Unit(FFTU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-12

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% FFT Unit(FFTU) finish the FFT for input data using a FFT IP
//% core.
//% 
//% **Timing**
//% 
//% 1. configure the IP core as FFT, pipelined stream, no real time mode
//% 2. stream input,  stream output
//% 
//% @note using unscale mode incase of overflow, need to be truncated in
//%       preamble, signal & preamble wrapper(it's depend on the values in 
//%       computation).
module FFTU (
    input                        clk,       //% working clock
    input                        rst,       //% synchornous reset, active high
    input        signed  [11:0]  di_re,     //% input data, real part
    input        signed  [11:0]  di_im,     //% input data, image part
    input                        di_vld,    //% input data valid flag
    output  reg  signed  [21:0]  do_re,     //% output data after FFT, real part
    output  reg  signed  [21:0]  do_im,     //% output data after FFT, image part
    output  reg                  do_vld     //% output data valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // configure the FFT core

    wire [7 :0]  s_config_tdata;
    reg          s_config_tvalid;
    wire         s_config_tready;

    localparam  FWD = 1'b1;                 //% FFT mode
    assign s_config_tdata = {6'b0, FWD};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_config_tvalid <= 1;
        end
        else begin
            if (s_config_tready) begin
                s_config_tvalid <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // transform

    reg  [31:0]  s_data_tdata;
    reg          s_data_tvalid;
    wire         s_data_tready;
    reg          s_data_tlast;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_data_tdata <= 0;
            s_data_tvalid <= 0;
        end
        else begin
            s_data_tdata <= {4'b0, di_im, 4'b0, di_re};
            s_data_tvalid <= di_vld;
        end
    end

    localparam      SAMPLES_CNT_MAX = `N - 1;
    reg  [12:0]     samples_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            samples_cnt <= 0;
        end
        else begin
            if (samples_cnt == SAMPLES_CNT_MAX) begin
                samples_cnt <= 0;
            end
            else if (s_data_tvalid) begin
                samples_cnt <= samples_cnt + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_data_tlast <= 0;
        end
        else begin
            if (samples_cnt == SAMPLES_CNT_MAX - 1) begin
                s_data_tlast <= 1;
            end
            else begin
                s_data_tlast <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // for debug

    wire    event_frame_started;
    wire    event_tlast_unexpected;
    wire    event_tlast_missing;
    wire    event_status_channel_halt;
    wire    event_data_in_channel_halt;
    wire    event_data_out_channel_halt;

    //--------------------------------------------------------------------------
    // output

    // the output is 22 bits incase of overflow
    wire  [47:0]  m_data_tdata;
    wire          m_data_tvalid;
    wire          m_data_tready;
    wire          m_data_tlast;

    assign m_data_tready = 1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re  <= 0;
            do_im  <= 0;
            do_vld <= 0;
        end
        else begin
            do_re  <= m_data_tdata[21: 0];
            do_im  <= m_data_tdata[45:24];
            do_vld <= m_data_tvalid;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the FFT IP core

    FFTU_FFT U_FFTU_FFT (
        .aclk(clk),                                                // input wire aclk
        
        .s_axis_config_tdata(s_config_tdata),                  // input wire [7 : 0] s_axis_config_tdata
        .s_axis_config_tvalid(s_config_tvalid),                // input wire s_axis_config_tvalid
        .s_axis_config_tready(s_config_tready),                // output wire s_axis_config_tready
        
        .s_axis_data_tdata(s_data_tdata),                      // input wire [31 : 0] s_axis_data_tdata
        .s_axis_data_tvalid(s_data_tvalid),                    // input wire s_axis_data_tvalid
        .s_axis_data_tready(s_data_tready),                    // output wire s_axis_data_tready
        .s_axis_data_tlast(s_data_tlast),                      // input wire s_axis_data_tlast
        
        .m_axis_data_tdata(m_data_tdata),                      // output wire [47 : 0] m_axis_data_tdata
        .m_axis_data_tvalid(m_data_tvalid),                    // output wire m_axis_data_tvalid
        .m_axis_data_tready(m_data_tready),                    // input wire m_axis_data_tready
        .m_axis_data_tlast(m_data_tlast),                      // output wire m_axis_data_tlast
        
        .event_frame_started(event_frame_started),                  // output wire event_frame_started
        .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
        .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
        .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
        .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
        .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
    );

endmodule