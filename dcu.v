//% @file dcu.v
//% @brief Implementation file of Data Combination Unit(DCU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-05-21

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Data Combination Unit(DCU) finish the combination of signal & payload data
//% using 2 simple dual-port RAM, one is for signal, and the other is for payload.
//% 
//% **Timing:**
//% 1. combine the {re, im} data into a new 24-bits data
//% 2. write the new data into the RAM
//% 3. when all writing is done, read out the data continous(adding white space 
//%    before and after each 480 data)
//%
//% @warning the downstream logic IFFT_CP module require there must be a CP gap
//%          between every 2 input symbols, so the output of this module has
//%          extra CP gap which is not the true cp!
module DCU (
    input                        new_frame,         //% flag of new frame data, work as reset signal
    // signal        
    input                        signal_clk,        //% working clock
    input  signed  [11:0]        signal_di_re,      //% input signal data_re
    input  signed  [11:0]        signal_di_im,      //% input signal data_im
    input                        signal_di_vld,     //% input signal data valid
    // payload       
    input                        payload_clk,       //% working clock
    input  signed  [11:0]        payload_di_re,     //% input payload data_re
    input  signed  [11:0]        payload_di_im,     //% input payload data_im
    input          [3:0]         payload_di_num,    //% number of total payload OFDM 
                                                    //% symbols in one frame
    input                        payload_di_sym_end,//% end flag of each OFDM symbol
    input                        payload_di_vld,    //% input payload data valid

    input                        clk_o,             //% working clock for output
    output  reg  signed  [11:0]  do_re,             //% output data_re
    output  reg  signed  [11:0]  do_im,             //% output data_im
    output  reg                  do_last,           //%
    output  reg                  do_vld             //% output data valid
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // write signal data into modulated_signal RAM via port A

    reg   signed  [23:0]  signal_di;   //% {re, im} signal
    //% combine the real & image part of signal data
    always @(posedge signal_clk) begin
        signal_di <= {signal_di_re, signal_di_im};
    end

    reg     signal_wea;     //% signal write enable
    //% generate the write enable for signal
    always @(posedge signal_clk) begin
        signal_wea <= signal_di_vld;
    end

    reg  [8:0]  signal_addra;      //% writing address for signal RAM
    //% generate the writing address for signal
    always @(posedge signal_clk) begin
        if (new_frame) begin
            signal_addra <= 9'b1_1111_1111;   // the last one address
        end
        else begin
            if (signal_di_vld) begin
                signal_addra <= signal_addra + 1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // write payload data into modulated_payload RAM via port A

    reg  signed  [23:0]  payload_di;   //% {re, im} payload
    //% combine the real & image part of payload data
    always @(posedge payload_clk) begin
        payload_di <= {payload_di_re, payload_di_im};
    end

    reg     payload_wea;    //% payload write enable
    //% generate the write enable for payload
    always @(posedge payload_clk) begin
        payload_wea <= payload_di_vld;
    end

    reg  [12:0]  payload_addra;     //% writing address for payload RAM
    //% generate the writing address for payload
    always @(posedge payload_clk) begin
        if (new_frame) begin
            payload_addra <= 13'b1_1111_1111_1111;
        end
        else begin
            if (payload_di_vld) begin
                payload_addra <= payload_addra + 1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // detect the end of write, and start to read

    reg  [3:0]   sym_cnt;   //% counter for input payload symbols
    //% cnt the number of payload symbols, to decide the start time of output
    always @(posedge clk_o) begin
        if (new_frame) begin
            sym_cnt <= 0;
        end
        else begin
            if (sym_cnt == payload_di_num) begin
                sym_cnt <= 0;
            end
            else if (payload_di_sym_end)begin
                sym_cnt <= sym_cnt + 1;
            end
        end
    end

    reg     wr_done;    //% write done flag
    //% get the end flag of writing
    always @(posedge clk_o) begin
        if (sym_cnt == payload_di_num && sym_cnt != 0) begin
            wr_done <= 1;
        end
        else begin
            wr_done <= 0;
        end
    end

    //--------------------------------------------------------------------------
    // read signal from RAM

    localparam    SIGNAL_CNT_MAX = `N - 1 + `CP_LEN;  //% 512 sc + 32 cp
    reg           signal_cnt_en;  //% signal_cnt enable
    reg    [9:0]  signal_cnt;    //% signal data output counter
    //% set count enable value
    always @(posedge clk_o) begin
        if (new_frame) begin
            signal_cnt_en <= 0;
        end
        else begin
            if (wr_done) begin
                signal_cnt_en <= 1;
            end
            if (signal_cnt == SIGNAL_CNT_MAX) begin
                signal_cnt_en <= 0;
            end
        end
    end
    //% count the number of signal data while output
    always @(posedge clk_o) begin
        if (new_frame) begin
            signal_cnt <= 0;
        end
        else begin
            if (signal_cnt_en) begin
                signal_cnt <= signal_cnt + 1;
            end
        end
    end

    reg   [8:0]   signal_addrb;      //% signal reading address
    //% set the read address for signal
    always @(posedge clk_o) begin
        if (new_frame) begin
            signal_addrb <= 9'b1_1111_1111;
        end
        else begin
            if (signal_cnt < `SPACE_NUM/2-4) begin  // RAM read latency = 2, + 2 level output reg
                signal_addrb <= 9'b1_1111_1111;
            end
            else begin
                signal_addrb <= signal_addrb + 1;
            end
        end
    end

    wire  signed  [23:0]  signal_doutb;     //% output from the signal RAM 
    reg   signed  [11:0]  signal_do_re;     //% signal data output, real part
    reg   signed  [11:0]  signal_do_im;     //% signal data output, image part
    //% get the final signal output
    always @(posedge clk_o) begin
        if (signal_cnt < `SPACE_NUM/2-1 || signal_cnt > (`N-`SPACE_NUM/2-2)) begin
            signal_do_re <= 0;
            signal_do_im <= 0;
        end
        else begin
            signal_do_re <= signal_doutb[23:12];
            signal_do_im <= signal_doutb[11: 0];
        end
    end

    //--------------------------------------------------------------------------
    // read payload from RAM

    reg             payload_cnt_en;     //% payload_cnt enable flag
    reg     [12:0]  payload_cnt;        //% payload data output counter
    wire    [12:0]  payload_cnt_max;    //% max vaule of payload-cnt

    reg             cp_cnt_en;          //% cp_cnt enable flag
    reg     [5 :0]  cp_cnt;             //% cp samples counter
    wire    [5 :0]  cp_cnt_max;         //% number of total cp space samples

    //% calculate the value of payload_cnt_max
    assign  payload_cnt_max = payload_di_num << 9;  //% 512 = 2^9
    //% calcualte the number of total cp samples
    assign cp_cnt_max = `CP_LEN;        //% CP_LEN = 32 = 2^5

    //% set the payload_cnt_en
    always @(posedge clk_o) begin
        if (new_frame) begin
            payload_cnt_en <= 0;
        end
        else begin
            if (signal_cnt == SIGNAL_CNT_MAX) begin     // signal segment end
                payload_cnt_en <= 1;
            end
            if (cp_cnt == cp_cnt_max && payload_cnt < payload_cnt_max-1) begin // every cp end
                payload_cnt_en <= 1;
            end
            if (cp_cnt_en && cp_cnt == 0) begin     // in cp period
                payload_cnt_en <= 0;
            end
            if (payload_cnt == payload_cnt_max-1) begin // payload segment end
                payload_cnt_en <= 0;
            end
        end
    end

    //% get the cp_cnt_en value
    always @(posedge clk_o) begin
        if (new_frame) begin
            cp_cnt_en <= 0;
        end
        else begin
            if (payload_cnt[8:0] == `N-2) begin
                cp_cnt_en <= 1;
            end
            if (cp_cnt == cp_cnt_max) begin
                cp_cnt_en <= 0;
            end
        end
    end
    //% get the cp_cnt value
    always @(posedge clk_o) begin
        if (new_frame) begin
            cp_cnt <= 0;
        end
        else begin
            if (cp_cnt_en) begin
                cp_cnt <= cp_cnt + 1;
            end
            else begin
                if (cp_cnt == cp_cnt_max+1) begin
                    cp_cnt <= 0;
                end
            end
        end
    end

    //% count the number of payload data while output
    always @(posedge clk_o) begin
        if (new_frame) begin
            payload_cnt <= 0;
        end
        else begin
            if (payload_cnt_en) begin
                payload_cnt <= payload_cnt + 1;
            end
        end
    end

    reg   [12:0]  payload_addrb;    //% signal reading address
    //% set the read address for signal
    always @(posedge clk_o) begin
        if (new_frame) begin
            payload_addrb <= 13'b1_1111_1111_1111;
        end
        else begin
            if (payload_cnt[8:0] < (`SPACE_NUM/2-4) || payload_cnt[8:0] >= (`N-`SPACE_NUM/2-4) ) begin
                // stop increase the addrb
            end
            else begin
                payload_addrb <= payload_addrb + 1;
            end
        end
    end

    wire  signed  [23:0]  payload_doutb;    //% data read out from payload RAM
    reg   signed  [11:0]  payload_do_re;    //% payload data output, real part
    reg   signed  [11:0]  payload_do_im;    //% payload data output, image part
    //% get the final signal output
    always @(posedge clk_o) begin
        if (payload_cnt[8:0] < (`SPACE_NUM/2-1) || payload_cnt[8:0] > (`N-`SPACE_NUM/2-2)) begin
            payload_do_re <= 0;
            payload_do_im <= 0;
        end
        else begin
            payload_do_re <= payload_doutb[23:12];
            payload_do_im <= payload_doutb[11: 0];
        end
    end

    //--------------------------------------------------------------------------
    // get the final output

    always @(posedge clk_o) begin
        if (signal_cnt_en) begin
            do_re <= signal_do_re;
            do_im <= signal_do_im;
        end
        else begin
            do_re <= payload_do_re;
            do_im <= payload_do_im;
        end
    end

    always @(posedge clk_o) begin
        if (new_frame) begin
            do_last <= 0;
        end
        else begin
            if (signal_cnt == `N-1) begin
                do_last <= 1;
            end
            else if (payload_cnt > 0 && payload_cnt[8:0] == `N-1) begin
                do_last <= 1;
            end
            else begin
                do_last <= 0;
            end
        end
    end


    always @(posedge clk_o) begin
        if (new_frame) begin
            do_vld <= 0;
        end
        else begin
            do_vld <= signal_cnt_en || payload_cnt_en || cp_cnt_en;
        end
    end

    //--------------------------------------------------------------------------
    // Instantiate a true dual port RAM

    modulated_signal u_modulated_signal (
        .clka(signal_clk),    // input wire clka
        .wea(signal_wea),      // input wire [0 : 0] wea
        .addra(signal_addra),  // input wire [8 : 0] addra
        .dina(signal_di),    // input wire [23 : 0] dina

        .clkb(clk_o),    // input wire clkb
        .addrb(signal_addrb),  // input wire [8 : 0] addrb
        .doutb(signal_doutb)  // output wire [23 : 0] doutb
    );

    modulated_payload u_modulated_payload (
        .clka(payload_clk),    // input wire clka
        .wea(payload_wea),      // input wire [0 : 0] wea
        .addra(payload_addra),  // input wire [12 : 0] addra
        .dina(payload_di),    // input wire [23 : 0] dina

        .clkb(clk_o),    // input wire clkb
        .addrb(payload_addrb),  // input wire [12 : 0] addrb
        .doutb(payload_doutb)  // output wire [23 : 0] doutb
    );

endmodule