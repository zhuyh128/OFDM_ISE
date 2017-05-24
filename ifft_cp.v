//% @file ifft_cp.v
//% @brief Implementation file of IFFT & CP(IFFT_CP) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-23

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% IFFT & CP module finish the IFFT and cyclic prefix operation for input data
//% {signal, paylaod}.
//% 
//% **Timing**
//% 
//% 1. input continous data
//% 2. after some latency(by the IP core), ouptut the result continously
//% 
//% @note: the real time and pipelined stream mode of IP core requires there must
//%        be a CP gap between every N input samples.
module IFFT_CP (
    input                        clk,         //% working clock
    input                        new_frame,   //% new frame flag, working as reset
    input  signed  [11:0]        di_re,       //% input data, real part
    input  signed  [11:0]        di_im,       //% input data, image part
    input                        di_last,     //% last sample flag in every symbol
    input          [3:0]         di_sym_num,  //% number of payload symbols
    input                        di_vld,      //% input data valid flag

    output  reg  signed  [11:0]  do_re,       //% output data, real part
    output  reg  signed  [11:0]  do_im,       //% output data, image part
    output  reg                  do_vld       //% output data valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // generate the reset signal for IP core:
    // the ARESETn(active low) require last 2 cycles at least, the input
    // new_frame(active high) is synchronized as 3 clock

    // reg  rstn1;     //% local tmp of reset signal to IP core
    // reg  rstn2;     //% local tmp of reset signal to IP core
    // wire aresetn;   //% reset signal to the IP core
    // always @(posedge clk) begin
    //     rstn1 <= ~new_frame;
    //     rstn2 <= rstn1;
    // end
    // //% generate the reset signal to the IP core
    // assign aresetn = ~(rstn1 ^ rstn2);

    reg  aresetn;

    always @(posedge clk) begin
        aresetn <= ~new_frame;
    end

    //--------------------------------------------------------------------------
    // Configure the IP core in IFFT mode, scale = 1/N

    localparam  FWD_INV = 1'b0;                 //% IFFT mode
    localparam  SCALE_SCH = 10'b01_10_10_10_10; //% scale schedule

    wire  [31:0]  config_tdata;  //% configure data
    //% config the core to work under the IFFT, cp = 32, scale = [1,2,2,2] mode
    assign config_tdata = {5'b0, SCALE_SCH, FWD_INV, 7'b0, `CP_LEN};

    reg    config_tvalid = 0;  //% config_dat valid flag
    //% config the core during reset period
    always @(posedge clk or negedge aresetn) begin
        if (!aresetn) begin
            config_tvalid <= 1;
        end
        else begin
            if (config_tready) begin
                config_tvalid <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Input data

    wire  s_data_tready;          //% core output flag to single ready state
    reg  [31:0]  s_data_tmp0;     //% local tmp for s_data_tdata
    reg  [31:0]  s_data_tdata;    //% input data to be transformed
    //% generate the local tmp
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            s_data_tmp0 <= 0;
        end
        else begin
            s_data_tmp0 <= {4'b0, di_im, 4'b0, di_re};
        end
    end
    //% generate the data into core
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            // reset
            s_data_tdata <= 0;
        end
        else begin
            s_data_tdata <= s_data_tmp0;
        end
    end

    reg         s_data_last;      //% flag for the last samples in every symbol
    //% algin the s_data_last & s_data_tdata
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            s_data_last <= 0;
        end
        else begin
            s_data_last <= di_last;
        end
    end

    reg         s_data_tvalid;    //% input data valid flag
    //% generate the data valid flag
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            s_data_tvalid <= 0;
        end
        else begin
            s_data_tvalid <= di_vld;
        end
    end

    //--------------------------------------------------------------------------
    // Output data

    wire  [31:0]  m_data_tdata;     //% core output result
    wire          m_data_tvalid;    //% core output valid
    //% get the module output from core output data
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= m_data_tdata[11: 0];
            do_im <= m_data_tdata[27:16];
        end
    end

    wire          m_data_tlast;     //% IP core output last sample flag
    reg   [3:0]   sym_cnt;          //% output symbols counter
    //% count the number of output symbols
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            sym_cnt <= 0;
        end
        else begin
            if (m_data_tlast) begin
                sym_cnt <= sym_cnt + 1;
            end
        end
    end

    //% get output valid flag
    always @(posedge clk or posedge new_frame) begin
        if (new_frame) begin
            // reset
            do_vld <= 0;
        end
        else begin
            if (sym_cnt < di_sym_num ) begin  // ATTENTION: 1 signal + 5 payload
                                                 //          = 6 symbols
                do_vld <= m_data_tvalid;
            end
            else begin
                do_vld <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // only for debug

    /*wire event_frame_started;
    wire event_tlast_unexpected;
    wire event_tlast_missing;
    wire event_data_in_channel_halt;*/


    //--------------------------------------------------------------------------
    // Instantiate the IFFT IP core

    IFFT_CP_IPCORE U_IFFT_CP_IPCORE (
        .aclk(clk),                                              // input wire aclk
        .aresetn(aresetn),                                        // input wire aresetn
        .s_axis_config_tdata(config_tdata),                // input wire [31 : 0] s_axis_config_tdata
        .s_axis_config_tvalid(config_tvalid),              // input wire s_axis_config_tvalid
        .s_axis_config_tready(config_tready),              // output wire s_axis_config_tready
        
        .s_axis_data_tdata(s_data_tdata),                    // input wire [31 : 0] s_axis_data_tdata
        .s_axis_data_tvalid(s_data_tvalid),                  // input wire s_axis_data_tvalid
        .s_axis_data_tready(s_data_tready),                  // output wire s_axis_data_tready
        .s_axis_data_tlast(s_data_last),                    // input wire s_axis_data_tlast
        
        .m_axis_data_tdata(m_data_tdata),                    // output wire [31 : 0] m_axis_data_tdata
        .m_axis_data_tvalid(m_data_tvalid),                  // output wire m_axis_data_tvalid
        .m_axis_data_tlast(m_data_tlast),                    // output wire m_axis_data_tlast
        
        // the event is unused in downstream logic, only for debug

        .event_frame_started(/*event_frame_started*/),                // output wire event_frame_started
        .event_tlast_unexpected(/*event_tlast_unexpected*/),          // output wire event_tlast_unexpected
        .event_tlast_missing(/*event_tlast_missing*/),                // output wire event_tlast_missing
        .event_data_in_channel_halt(/*event_data_in_channel_halt*/)  // output wire event_data_in_channel_halt
    );

endmodule