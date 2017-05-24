//% @file csu.v
//% @brief Implementation file of Constellation Scramble Unit(CMU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-20

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Constellation Scramble Unit(CSU) funish the constellation scramble for input
//% data{signal & payload} segment using the LFSR in G.hn
//% 
//% **Timing**
//% 
//% 1. in 1st clock period, scramble current input if input is valid, generate 
//%    the feedback at the same time.
//% 2. in 2nd clock period, shift the LFSR for next input data.
//% 
//% @warning the input must not be continous, because shift & scramble for one 
//           input data need 2 clock cycle at least.
module CSU (
    // input
    input                      signal_clk,          //% working clock for signal
    input                      signal_rst,          //% asynchronous reset for signal, active high
    input      signed  [11:0]  signal_di_re,        //% input signal data, real part
    input      signed  [11:0]  signal_di_im,        //% input signal data, image part
    input                      signal_di_vld,       //% input signal data valid flag
    // output
    output reg signed  [11:0]  signal_do_re,        //% scrambled signal data, real part
    output reg signed  [11:0]  signal_do_im,        //% scrambled signal data, image part
    output reg                 signal_do_vld,       //% scrambled signal data valid flag

    // input
    input                      payload_clk,         //% working clock for payload
    input                      payload_rst,         //% asynchronous reset for paylaod, active high
    input      signed  [11:0]  payload_di_re,       //% input payload data, real part
    input      signed  [11:0]  payload_di_im,       //% input payload data, image part
    input                      payload_di_sym_end,  //% end of one OFDM symbol flag
    input                      payload_di_vld,      //% input payload data valid flag

    // output
    output reg signed  [11:0]  payload_do_re,       //% scrambled payload data, real part
    output reg signed  [11:0]  payload_do_im,       //% scrambled payload data, image part
    output reg                 payload_do_sym_end,  //% end of one OFDM symbol flag
    output reg                 payload_do_vld       //% scrambled payload data valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // for signal segment

    reg    [0:12]  LFSR_signal;       //% LFSR for signal segment
    //% scramble current input signal data
    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            signal_do_re <= 0;
            signal_do_im <= 0;
        end
        else begin
            if (signal_di_vld) begin
                case (LFSR_signal[0:1])
                    2'b00: begin
                        signal_do_re <= signal_di_re;
                        signal_do_im <= signal_di_im;
                    end
                    2'b10: begin
                        signal_do_re <= -signal_di_im;
                        signal_do_im <=  signal_di_re;
                    end
                    2'b01: begin
                        signal_do_re <= -signal_di_re;
                        signal_do_im <= -signal_di_im;
                    end
                    2'b11: begin
                        signal_do_re <=  signal_di_im;
                        signal_do_im <= -signal_di_re;
                    end
                endcase
            end
        end
    end

    wire    fbk1_signal;    //% feedback1 for LFSR_signal
    wire    fbk2_signal;    //% feedback2 for LFSR_signal
    //% generate the feedback for next signal data
    assign fbk1_signal = LFSR_signal[7] + LFSR_signal[10] + LFSR_signal[11] + LFSR_signal[12];
    assign fbk2_signal = LFSR_signal[6] + LFSR_signal[9] + LFSR_signal[10] + LFSR_signal[11];

    //% shift the LFSR_signal for next input data while scrambling current data
    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            LFSR_signal <= 13'b1_1111_1111_1111;
        end
        else begin
            if (signal_di_vld) begin
                LFSR_signal <= {fbk2_signal, fbk1_signal, LFSR_signal[0:10]};
            end
        end
    end

    //% generate the signal output valid flag
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
    // for payload segment

    reg    [0:12]   LFSR_payload;   //% LFSR for payload segment
    //% scrambel current input payload data
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_do_re <= 0;
            payload_do_im <= 0;
        end
        else begin
            if (payload_di_vld) begin
                case (LFSR_payload[0:1])
                    2'b00: begin
                        payload_do_re <= payload_di_re;
                        payload_do_im <= payload_di_im;
                    end
                    2'b10: begin
                        payload_do_re <= -payload_di_im;
                        payload_do_im <=  payload_di_re;
                    end
                    2'b01: begin
                        payload_do_re <= -payload_di_re;
                        payload_do_im <= -payload_di_im;
                    end
                    2'b11: begin
                        payload_do_re <=  payload_di_im;
                        payload_do_im <= -payload_di_re;
                    end
                endcase
            end
        end
    end

    wire    fbk1_payload;    //% feedback1 for LFSR_payload
    wire    fbk2_payload;    //% feedback2 for LFSR_payload
    //% generate the feedback for next payload data
    assign fbk1_payload = LFSR_payload[7] + LFSR_payload[10] + LFSR_payload[11] + LFSR_payload[12];
    assign fbk2_payload = LFSR_payload[6] + LFSR_payload[9] + LFSR_payload[10] + LFSR_payload[11];

    //% shift the LFSR_payload for next input data while scrambling current data
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            LFSR_payload <= 13'b1_1111_1111_1111;
        end
        else begin
            if (payload_di_sym_end) begin
                LFSR_payload <= 13'b1_1111_1111_1111;
            end
            else begin
                if (payload_di_vld) begin
                    LFSR_payload <= {fbk2_payload, fbk1_payload, LFSR_payload[0:10]};
                end
            end
        end
    end

    //% generate the payload_do_sym_end
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            payload_do_sym_end <= 0;
        end
        else begin
            payload_do_sym_end <= payload_di_sym_end;
        end
    end

    //% generate the payload output valid flag
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_do_vld <= 0;
        end
        else begin
		      payload_do_vld <= payload_di_vld;
        end
    end

endmodule