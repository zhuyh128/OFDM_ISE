//% @file cmu.v
//% @brief Implementation file of Constellation Map Unit(CMU) module.
//% 
//% @author  Qian Gu, have been odified by Xu
//% @version 1.0
//% @date 2015-05-19
//% version1.0    1-->positive      0-->negative
//% version1.1    1-->negative      0-->positive
//% Modified by Xu Xunzhi to version1.1

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Constellation Mapping Unit(CMU) finish the constellation mapping for input
//% data {signal, payload}, including scaling.
//% 
//% **Timing**
//% 
//% 1. latency = 1 clock period
module CMU (
    // signal
    input                        signal_clk,         //% working clock for signal bits
    input                        signal_rst,         //% asynchronous reset for signal, active high
    input                [1 :0]  signal_di,          //% input data, signal
    input                        signal_di_vld,      //% signal_di input valid flag

    output  reg  signed  [11:0]  signal_do_re,       //% mapped signal, real part
    output  reg  signed  [11:0]  signal_do_im,       //% mapped signal, image part
    output  reg                  signal_do_vld,      //% signal_do_xx valid flag

    // payload
    input                        payload_clk,        //% working clock for payload bits
    input                        payload_rst,        //% asynchronous reset for paylaod, active high
    input                [3 :0]  payload_di,         //% input data, payload
    input                        payload_di_sym_end, //% end flag of each OFDM symbol
    input                        payload_di_vld,     //% payload_di input valid flag

    output  reg  signed  [11:0]  payload_do_re,      //% mapped payload, real part
    output  reg  signed  [11:0]  payload_do_im,      //% mapped paylaod, image parts
    output  reg                  payload_do_sym_end, //% end flag of each OFDM symbol
    output  reg                  payload_do_vld      //% payload_do_xx valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // for Signal segment
    
    //% for version1.0
    // localparam      SIGNAL_V1 = -1115;      //% QPSK mapping value1
    // localparam      SIGNAL_V2 =  1115;      //% QPSK mapping value2
    
    //% for version1.1, need to modify the demodulation module in scdm.v
    localparam      SIGNAL_V1 = 1115;       //% QPSK mapping value1
    localparam      SIGNAL_V2 = -1115;      //% QPSK mapping value2
    
    //% mapping the signal bits
    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            signal_do_re <= 0;
            signal_do_im <= 0;
        end
        else begin
            if (signal_di_vld) begin
                // real part
                if (signal_di[0]) begin
                    signal_do_re <= SIGNAL_V2;
                end
                else begin
                    signal_do_re <= SIGNAL_V1;
                end
                // image part
                if (signal_di[1]) begin
                    signal_do_im <= SIGNAL_V2;
                end
                else begin
                    signal_do_im <= SIGNAL_V1;
                end
            end
            else begin
                signal_do_re <= 0;
                signal_do_im <= 0;
            end
        end
    end

    //% generate signal_do_vld
    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            signal_do_vld <= 0;
        end
        else begin
            signal_do_vld <= signal_di_vld;
        end
    end

    //--------------------------------------------------------------------------
    // for Payload segment

    //% for version1.0
    // localparam      PAYLOAD_V1 =   499;     //% 16QAM mapping value1
    // localparam      PAYLOAD_V2 =  -499;     //% 16QAM mapping value2
    // localparam      PAYLOAD_V3 =  1497;     //% 16QAM mapping value3
    // localparam      PAYLOAD_V4 = -1497;     //% 16QAM mapping value4

    //% for version1.1, need to modify the demodulation module in pcmi.v(line 176 to 196)
    //% and need to modify the pllr calculation in file llrc.v(line 400)
    localparam      PAYLOAD_V1 = 499;
    localparam      PAYLOAD_V2 = 1497;
    localparam      PAYLOAD_V3 = -499;
    localparam      PAYLOAD_V4 = -1497;

    //% mapping the payload bits
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_do_re <= 0;
            payload_do_im <= 0;
        end
        else begin
            if (payload_di_vld) begin
                // real part
                case (payload_di[1:0])
                    2'b00: begin
                        payload_do_re <= PAYLOAD_V2;
                    end
                    2'b01: begin
                        payload_do_re <= PAYLOAD_V4;
                    end
                    2'b10: begin
                        payload_do_re <= PAYLOAD_V1;
                    end
                    2'b11: begin
                        payload_do_re <= PAYLOAD_V3;
                    end
                endcase
                // image part
                case (payload_di[3:2])
                    2'b00: begin
                        payload_do_im <= PAYLOAD_V2;
                    end
                    2'b01: begin
                        payload_do_im <= PAYLOAD_V4;
                    end
                    2'b10: begin
                        payload_do_im <= PAYLOAD_V1;
                    end
                    2'b11: begin
                        payload_do_im <= PAYLOAD_V3;
                    end
                endcase
            end
            else begin
                payload_do_re <= 0;
                payload_do_im <= 0;
            end
        end
    end

    //% generate payload_do_vld
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_do_vld <= 0;
        end
        else begin
            payload_do_vld <= payload_di_vld;
        end
    end

    //% align the payload_do_vld and payload_do_sym_end
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_do_sym_end <= 0;
        end
        else begin
            payload_do_sym_end <= payload_di_sym_end;
        end
    end

endmodule