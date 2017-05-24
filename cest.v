//% @file cest.v
//% @brief Implementation file of Channel Estimation Unit(CEST) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-15

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Channel Estimation Unit (CEST) finish the estimation of channel.
//% 
//% **Theory & Timing**
//% 
//% 1. R = H*L + N
//% 2. H~ = R/L
//% 3. N~ = R - L*H~
//% 
//% **Timing**
//% 
//% 0. R/sqrt(N) first!
//% 1. FFT(R)
//% 2. H~ = R/L = (a*c+b*d)/(c^2+d^2) + (b*c-a*d)/(c^2+d^2)
//% 3. N~ = R - L*H~
//% 4. power of N~(sigma2)
//% 
//% @note to simplify the design, using only 4 symbol in estimation
//% @note divide sqrt(512) first, sqrt(512) ~= 22.5
//% @note saturation after fft
module CEST (
    input                   clk,                //% working clock
    input                   rst,                //% synchronous reset, active
                                                //% high
    input   signed  [11:0]  di_re,              //% input preamble, real part
    input   signed  [11:0]  di_im,              //% input preamble, image part
    input                   di_vld,             //% input preamble valid flag
    output  signed  [11:0]  H_estimated_re,     //% estimated H, real part
    output  signed  [11:0]  H_estimated_im,     //% estimated H, image part
    output                  H_estimated_vld,    //% estimated H valid flag
    output  signed  [11:0]  sigma2,             //% estimated noise power
    output                  sigma2_vld          //% sigma2 valid flag
    );

//=============================================================================
// Main Body of Code
    
    reg  done_rst;                      //Modified by baiyf
    reg  done_flag;
    //---------------------------------------------------------------------------
    // 0. preoperation, R/22.5


    //-------------------------------------------------------------------------
    // 1. FFT submodule finish the FFT for R
    // aligin the FFT output(R) with ROM output(L)

    wire                  fft_do_vld;
    wire  signed  [21:0]  fft_do_re;
    wire  signed  [21:0]  fft_do_im;

    wire                  fft_vld;
    wire  signed  [11:0]  fft_re;
    wire  signed  [11:0]  fft_im;

    assign fft_vld = fft_do_vld;
    assign fft_re  = fft_do_re[11:0];   // truncate to 12 bits(preamble)
    assign fft_im  = fft_do_im[11:0];


    //% align the FFT output and ROM output
    wire                  fft_vld_dly3;
    wire  signed  [11:0]  fft_re_dly3;
    wire  signed  [11:0]  fft_im_dly3;

    DLY3 #(.WIDTH(1))  fft_vld_dly  (
        .clk(clk),
        .rst(rst),
        .din(fft_vld),
        .dout(fft_vld_dly3)
        );

    DLY3 #(.WIDTH(12))  fft_re_dly  (
        .clk(clk),
        .rst(rst),
        .din(fft_re),
        .dout(fft_re_dly3)
        );

    DLY3 #(.WIDTH(12))  fft_im_dly  (
        .clk(clk),
        .rst(rst),
        .din(fft_im),
        .dout(fft_im_dly3)
        );

    //------------------------------------------------
    // save the FFT result(R) of input data into FIFO
    
    wire         fifo_re_full;
    wire         fifo_im_full;
    reg          fifo_wr_en;
    reg  [11:0]  fifo_din_re;
    reg  [11:0]  fifo_din_im;
    
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            fifo_wr_en <= 0;
            fifo_din_re <= 0;
            fifo_din_im <= 0;
        end
        else begin
            if (!fifo_re_full && !fifo_im_full) begin 
                fifo_wr_en <= fft_vld;
                fifo_din_re <= fft_re;
                fifo_din_im <= fft_im;
            end
            else begin
                fifo_wr_en <= 0;
                fifo_din_re <= 0;
                fifo_din_im <= 0;
            end
        end
    end

    //--------------------------------------------
    // when FFT core output data valid, start to 
    // read local data from ROM

    wire                   rom_ena;
    reg            [8 :0]  rom_addra;
    wire  signed   [11:0]  rom_douta_re;
    wire  signed   [11:0]  rom_douta_im;

    assign rom_ena = 1'b1;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rom_addra <= 9'b1_1111_1111;
        end
        else begin
            if (fft_vld && rom_addra == 9'd511) begin
                rom_addra <= 0;
            end
            else if (fft_vld) begin
                rom_addra <= rom_addra + 1;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 2. H~ = R/L = (a+b*j)/(c+d*j) = (a*c+b*d)/(c^2+d^2) + (b*c-a*d)/(c^2+d^2)


    //----------------------------------------------------------
    // step1. calculate the (ac+bd) & (bc-ad) using a multiplier

    // channel a is (a+b*j)
    reg          s1_a_tvalid;
    reg  [31:0]  s1_a_tdata;
    // channel b is (c-d*j)
    reg          s1_b_tvalid;
    reg  [31:0]  s1_b_tdata;
    
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s1_a_tvalid <= 0;
            s1_b_tvalid <= 0;
        end
        else begin
            s1_a_tvalid <= fft_vld_dly3;
            s1_b_tvalid <= fft_vld_dly3;
        end
    end
    
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s1_a_tdata <= 0;
            s1_b_tdata <= 0;
        end
        else begin
            s1_a_tdata <= {4'b0, fft_im_dly3, 4'b0, fft_re_dly3};
            s1_b_tdata <= {4'b0, -rom_douta_im, 4'b0, rom_douta_re};
        end
    end

    // multiplier output
    wire         m1_dout_tvalid;
    wire [63:0]  m1_dout_tdata;

    // get the dividend
    reg                  dividend_vld;
    reg  signed  [24:0]  dividend_re;
    reg  signed  [24:0]  dividend_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dividend_vld <= 0;
            dividend_re <= 0;
            dividend_im <= 0;
        end
        else begin
            if (m1_dout_tvalid) begin
                dividend_vld <= 1;
                dividend_re <= m1_dout_tdata[24: 0];
                dividend_im <= m1_dout_tdata[56:32];
            end
            else begin
                dividend_vld <= 0;
                dividend_re <= 0;
                dividend_im <= 0;
            end
        end
    end

    //--------------------------------------------------------------
    // step2.  because c+d*j is the ZC sequence, it has the constant 
    // amplitude = 1578*1578, so the divisor (c^2+d^2)/1578 = 1578 is 
    // a constant value.

    //% @note using a Divider IP core instead of logic resource for "/1578" 
    //%       operation to simplify the design at the cost of DSP slice.
    
    reg          divisor_vld;
    reg  [11:0]  divisor;
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            divisor_vld <= 0;
            divisor <= 0;
        end
        else begin
            if (m1_dout_tvalid) begin
                divisor_vld <= 1;
                divisor <= 12'd1578;
            end
            else begin
                divisor_vld <= 0;
                divisor <= 0;   // aviod invalid divisor(0)
            end
        end
    end

    reg          s2_dividend_tvalid;
    reg  [31:0]  s2_dividend_tdata;
    reg          s2_divisor_tvalid;
    reg  [15:0]  s2_divisor_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s2_dividend_tvalid <= 0;
            s2_divisor_tvalid <= 0;
        end
        else begin
            s2_dividend_tvalid <= dividend_vld;
            s2_divisor_tvalid <= divisor_vld;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s2_dividend_tdata <= 0;
            s2_divisor_tdata <= 0;
        end
        else begin
            s2_dividend_tdata <= {7'b0, dividend_re};
            s2_divisor_tdata <= {4'b0, divisor};
        end
    end

    wire          m2_dout_tvalid;
    wire  [47:0]  m2_dout_tdata;

    reg                  quotient_vld;
    reg  signed  [24:0]  quotient_re;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            quotient_vld <= 0;
        end
        else begin
            quotient_vld <= m2_dout_tvalid;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            quotient_re <= 0;
        end
        else begin
            quotient_re <= m2_dout_tdata[40:16];
        end
    end

    reg          s3_dividend_tvalid;
    reg  [31:0]  s3_dividend_tdata;
    reg          s3_divisor_tvalid;
    reg  [15:0]  s3_divisor_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s3_dividend_tvalid <= 0;
            s3_divisor_tvalid <= 0;
        end
        else begin
            s3_dividend_tvalid <= dividend_vld;
            s3_divisor_tvalid <= divisor_vld;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s3_dividend_tdata <= 0;
            s3_divisor_tdata <= 0;
        end
        else begin
            s3_dividend_tdata <= {7'b0, dividend_im};
            s3_divisor_tdata <= {4'b0, divisor};
        end
    end

    wire          m3_dout_tvalid;
    wire  [47:0]  m3_dout_tdata;

    reg  signed  [24:0]  quotient_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            quotient_im <= 0;
        end
        else begin
            quotient_im <= m3_dout_tdata[40:16];
        end
    end

    //----------------------------------------
    // step3. calculate L*H~ / 1578

    // get the H~
    reg                  H_vld;
    reg  signed  [11:0]  H_re;
    reg  signed  [11:0]  H_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            H_vld <= 0;
            H_re  <= 0;
            H_im  <= 0;
        end
        else begin
            H_vld <= quotient_vld;
            H_re  <= quotient_re[11:0];
            H_im  <= quotient_im[11:0];
        end
    end

    // instantiate submodule AVEH calculate the average of H~

    wire                  H_vld_dly3;
    wire  signed  [11:0]  H_re_dly3;
    wire  signed  [11:0]  H_im_dly3;

    DLY3 #(.WIDTH(1)) u_H_vld_dly3 (
        .clk(clk),
        .rst(rst),
        .din(H_vld),
        .dout(H_vld_dly3)
        );

    DLY3 #(.WIDTH(12)) u_H_re_dly3 (
        .clk(clk),
        .rst(rst),
        .din(H_re),
        .dout(H_re_dly3)
        );

    DLY3 #(.WIDTH(12)) u_H_im_dly3 (
        .clk(clk),
        .rst(rst),
        .din(H_im),
        .dout(H_im_dly3)
        );

    wire         rom1_ena;
    reg  [8 :0]  rom1_addra;

    wire  signed  [11:0]  rom1_douta_re;
    wire  signed  [11:0]  rom1_douta_im;

    assign rom1_ena = 1;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rom1_addra <= 9'b1_1111_1111;
        end
        else begin
            if (H_vld && rom1_addra == 9'd511) begin
                rom1_addra <= 0;
            end
            else if (H_vld) begin
                rom1_addra <= rom1_addra + 1;
            end
        end
    end
    
    reg          s4_a_tvalid;
    reg  [31:0]  s4_a_tdata;
    reg          s4_b_tvalid;
    reg  [31:0]  s4_b_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s4_a_tvalid <= 0;
            s4_b_tvalid <= 0;
        end
        else begin
            s4_a_tvalid <= H_vld_dly3;
            s4_b_tvalid <= H_vld_dly3;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s4_a_tdata <= 0;
            s4_b_tdata <= 0;
        end
        else begin
            s4_a_tdata <= {4'b0, H_im_dly3, 4'b0, H_re_dly3};
            s4_b_tdata <= {4'b0, rom1_douta_im, 4'b0, rom1_douta_re};
        end
    end

    wire          m4_dout_tvalid;
    wire  [63:0]  m4_dout_tdata;

    reg                  lh_vld;
    reg  signed  [24:0]  lh_re;
    reg  signed  [24:0]  lh_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            lh_vld <= 0;
            lh_re <= 0;
            lh_im <= 0;
        end
        else begin
            lh_vld <= m4_dout_tvalid;
            lh_re <= m4_dout_tdata[24: 0];
            lh_im <= m4_dout_tdata[56:32];
        end
    end

    reg                  s5_dividend_tvalid;
    reg  signed  [31:0]  s5_dividend_tdata;
    reg                  s5_divisor_tvalid;
    reg  signed  [15:0]  s5_divisor_tdata;

    wire                 m5_dout_tvalid;
    wire         [47:0]  m5_dout_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s5_dividend_tvalid <= 0;
            s5_dividend_tdata <= 0;
            s5_divisor_tvalid <= 0;
            s5_divisor_tdata <= 0;
        end
        else begin
            s5_dividend_tvalid <= lh_vld;
            s5_dividend_tdata <= {7'b0, lh_re};
            s5_divisor_tvalid <= lh_vld;
            s5_divisor_tdata <= {4'b0, 12'd1578};
        end
    end

    reg                  s6_dividend_tvalid;
    reg  signed  [31:0]  s6_dividend_tdata;
    reg                  s6_divisor_tvalid;
    reg  signed  [15:0]  s6_divisor_tdata;

    wire                 m6_dout_tvalid;
    wire         [47:0]  m6_dout_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s6_dividend_tvalid <= 0;
            s6_dividend_tdata <= 0;
            s6_divisor_tvalid <= 0;
            s6_divisor_tdata <= 0;
        end
        else begin
            s6_dividend_tvalid <= lh_vld;
            s6_dividend_tdata <= {7'b0, lh_im};
            s6_divisor_tvalid <= lh_vld;
            s6_divisor_tdata <= {4'b0, 12'd1578};
        end
    end

    reg                  lh_scaled_vld;
    reg  signed  [11:0]  lh_scaled_re;
    reg  signed  [11:0]  lh_scaled_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            lh_scaled_vld <= 0;
            lh_scaled_re <= 0;
            lh_scaled_im <= 0;
        end
        else begin
            lh_scaled_vld <= m5_dout_tvalid;
            lh_scaled_re <= m5_dout_tdata[27:16];    // [40:16], 12 bits from LSB
            lh_scaled_im <= m6_dout_tdata[27:16];
        end
    end

    //-------------------------------------------------------------------------
    // 3. calculate N = R - L*H

    // read R form FIFO
    reg           fifo_rd_en;
    wire          fifo_re_empty;
    wire          fifo_im_empty;

    // wire          fifo_do_valid;
    wire          fifo_re_do_valid;
    wire          fifo_im_do_valid;
    wire  [11:0]  fifo_dout_re;
    wire  [11:0]  fifo_dout_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            fifo_rd_en <= 0;
        end
        else begin
            if (!fifo_re_empty && !fifo_im_empty) begin
                fifo_rd_en <= lh_scaled_vld;
            end
            else begin
                fifo_rd_en <= 0;
            end
        end
    end

    wire  signed  [11:0]  lh_scaled_re_dly3;
    wire  signed  [11:0]  lh_scaled_im_dly3;

    DLY3 #(.WIDTH(12)) lh_scaled_re_dly (
        .clk(clk),
        .rst(rst),
        .din(lh_scaled_re),
        .dout(lh_scaled_re_dly3)
        );

    DLY3 #(.WIDTH(12)) lh_scaled_im_dly (
        .clk(clk),
        .rst(rst),
        .din(lh_scaled_im),
        .dout(lh_scaled_im_dly3)
        );

    reg                  noise_vld;
    reg  signed  [11:0]  noise_re;
    reg  signed  [11:0]  noise_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            noise_vld <= 0;
            noise_re <= 0;
            noise_im <= 0;
        end
        else begin
            noise_vld <= fifo_re_do_valid;
            noise_re <= fifo_dout_re - lh_scaled_re_dly3;
            noise_im <= fifo_dout_im - lh_scaled_im_dly3;
        end
    end

    //-------------------------------------------------------------------------
    // 4. calculate the power of noise

    reg          s7_a_tvalid;
    reg  [31:0]  s7_a_tdata;
    reg          s7_b_tvalid;
    reg  [31:0]  s7_b_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s7_a_tvalid <= 0;
            s7_b_tvalid <= 0;
        end
        else begin
            s7_a_tvalid <= noise_vld;
            s7_b_tvalid <= noise_vld;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s7_a_tdata <= 0;
            s7_b_tdata <= 0;
        end
        else begin
            s7_a_tdata <= {4'b0, noise_im, 4'b0, noise_re};
            s7_b_tdata <= {4'b0, -noise_im, 4'b0, noise_re};
        end
    end

    wire          m7_dout_tvalid;
    wire  [63:0]  m7_dout_tdata;


    reg                  noise_power_vld;
    reg  signed  [24:0]  noise_power_re;
    reg  signed  [24:0]  noise_power_im;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            noise_power_vld <= 0;
            noise_power_re <= 0;
            noise_power_im <= 0;
        end
        else begin
            noise_power_vld <= m7_dout_tvalid;
            noise_power_re <= m7_dout_tdata[24: 0];
            noise_power_im <= m7_dout_tdata[56:32];
        end
    end

    reg                  noise_power_sum_vld;
    reg  signed  [25:0]  noise_power_sum;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            noise_power_sum_vld <= 0;
            noise_power_sum <= 0;
        end
        else begin
            noise_power_sum_vld <= noise_power_vld;
            noise_power_sum <= noise_power_re + noise_power_im;
        end
    end

    //------------------------------------------
    // scale: power / 1578

    reg                  s8_dividend_tvalid;
    reg  signed  [31:0]  s8_dividend_tdata;
    reg                  s8_divisor_tvalid;
    reg  signed  [15:0]  s8_divisor_tdata;

    wire                 m8_dout_tvalid;
    wire         [47:0]  m8_dout_tdata;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s8_dividend_tvalid <= 0;
            s8_dividend_tdata <= 0;
            s8_divisor_tvalid <= 0;
            s8_divisor_tdata <= 0;
        end
        else begin
            s8_dividend_tvalid <= noise_power_sum_vld;
            s8_dividend_tdata <= {6'b0, noise_power_sum};
            s8_divisor_tvalid <= noise_power_sum_vld;
            s8_divisor_tdata <= {4'b0, 12'd1578};
        end
    end

    reg  signed  [11:0]  noise_power_scaled;
    reg                  noise_power_scaled_vld;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            noise_power_scaled <= 0;
            noise_power_scaled_vld <= 0;
        end
        else begin
            noise_power_scaled <= m8_dout_tdata[27:16]; // 12 bits
            noise_power_scaled_vld <= m8_dout_tvalid;
        end
    end

    always @(negedge sigma2_vld or posedge rst or posedge done_rst) begin       //Modified by baiyf
        if(rst||done_rst) begin
            done_flag <= 0;
        end
        else begin
            done_flag <= 1;
        end
    end
    
    always @(posedge clk ) begin                                                 //Modified by baiyf
        if(done_flag) begin
            done_rst <= 1;
        end
        else begin
            done_rst <= 0;
        end
    end
  
    
    // instantiate submodule to calculate the average of noise power
    
    //-------------------------------------------------------------------------
    // instantiate the submodule

    wire  signed  [11:0]  PUUFFTU_re;
    wire  signed  [11:0]  PUUFFTU_im;
    wire                  PUUFFTU_vld;
    //% sub module
    PUU CEST_PUU (
        .clk(clk),
        .rst(rst),
        .di_re(di_re),
        .di_im(di_im),
        .di_vld(di_vld),
        .do_re(PUUFFTU_re),
        .do_im(PUUFFTU_im), 
        .do_vld(PUUFFTU_vld)
    );

    //% sub module
    FFTU CEST_FFTU (
        .clk(clk),   
        .rst(rst),   
        .di_re(PUUFFTU_re), 
        .di_im(PUUFFTU_im), 
        .di_vld(PUUFFTU_vld),
        .do_re(fft_do_re), 
        .do_im(fft_do_im), 
        .do_vld(fft_do_vld) 
    );

    CEST_FIFO_RE U_CEST_FIFO_RE (
        .clk(clk),      // input wire clk
        .srst(rst),      // input wire srst
        .din(fifo_din_re),      // input wire [11 : 0] din
        .wr_en(fifo_wr_en),  // input wire wr_en
        .rd_en(fifo_rd_en),  // input wire rd_en
        .dout(fifo_dout_re),    // output wire [11 : 0] dout
        .full(fifo_re_full),    // output wire full
        .empty(fifo_re_empty),  // output wire empty
        .valid(fifo_re_do_valid)  // output wire valid
    );

    CEST_FIFO_IM U_CEST_FIFO_IM (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(fifo_din_im),      // input wire [11 : 0] din
        .wr_en(fifo_wr_en),  // input wire wr_en
        .rd_en(fifo_rd_en),  // input wire rd_en
        .dout(fifo_dout_im),    // output wire [11 : 0] dout
        .full(fifo_im_full),    // output wire full
        .empty(fifo_im_empty),  // output wire empty
        .valid(fifo_im_do_valid)  // output wire valid
    );

    //% ROM for L in R*conj(L)
    CEST_ROM_RE U_CEST_ROM_RE (
        .clka(clk),    // input wire clka
        .ena(rom_ena),      // input wire ena
        .addra(rom_addra),  // input wire [8 : 0] addra
        .douta(rom_douta_re)  // output wire [11 : 0] douta
    );

    //% ROM for L in R*conj(L)
    CEST_ROM_IM U_CEST_ROM_IM (
        .clka(clk),    // input wire clka
        .ena(rom_ena),      // input wire ena
        .addra(rom_addra),  // input wire [8 : 0] addra
        .douta(rom_douta_im)  // output wire [11 : 0] douta
    );

    //% complex multiplier used to calculate R*conj(L) = (ac+bd) + (bc-ad)*j
    CEST_MUL1 U_CEST_MUL1 (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s1_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s1_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s1_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s1_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(m1_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m1_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    //% calcualte R*conj(L) / (L*congj(L)) = R*conj(L) / 1578, real part
    CEST_DIVIDER1_RE U_CEST_DIVIDER1_RE (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s2_divisor_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s2_divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s2_dividend_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s2_dividend_tdata),    // input wire [31 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(m2_dout_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m2_dout_tdata)            // output wire [47 : 0] m_axis_dout_tdata
    );

    //% calcualte R*conj(L) / (L*congj(L)) = R*conj(L) / 1578, image part
    CEST_DIVIDER1_IM U_CEST_DIVIDER1_IM (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s3_divisor_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s3_divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s3_dividend_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s3_dividend_tdata),    // input wire [31 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(m3_dout_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m3_dout_tdata)            // output wire [47 : 0] m_axis_dout_tdata
    );

    //% ROM for L in L*H, real part
    CEST_ROM1_RE U_CEST_ROM1_RE (
        .clka(clk),    // input wire clka
        .ena(rom1_ena),      // input wire ena
        .addra(rom1_addra),  // input wire [8 : 0] addra
        .douta(rom1_douta_re)  // output wire [11 : 0] douta
    );

    //% ROM for L*H, image part
    CEST_ROM1_IM U_CEST_ROM1_IM (
        .clka(clk),    // input wire clka
        .ena(rom1_ena),      // input wire ena
        .addra(rom1_addra),  // input wire [8 : 0] addra
        .douta(rom1_douta_im)  // output wire [11 : 0] douta
    );

    //% calculate L*H
    CEST_MUL2 U_CEST_MUL2 (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s4_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s4_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s4_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s4_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(m4_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m4_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    //% calcualte (L*H) / 1578, real part
    CEST_DIVIDER2_RE U_CEST_DIVIDER2_RE (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s5_divisor_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s5_divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s5_dividend_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s5_dividend_tdata),    // input wire [31 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(m5_dout_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m5_dout_tdata)            // output wire [47 : 0] m_axis_dout_tdata
    );

    //% calcualte (L*H) / 1578, image part
    CEST_DIVIDER2_IM U_CEST_DIVIDER2_IM (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s6_divisor_tvalid),    // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s6_divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s6_dividend_tvalid),  // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s6_dividend_tdata),    // input wire [31 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(m6_dout_tvalid),          // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m6_dout_tdata)            // output wire [47 : 0] m_axis_dout_tdata
    );

    CEST_MUL3 U_CEST_MUL3 (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s7_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s7_a_tdata),          // input wire [31 : 0]    s_axis_a_tdata
        .s_axis_b_tvalid(s7_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s7_b_tdata),          // input wire [31 : 0]    s_axis_b_tdata
        .m_axis_dout_tvalid(m7_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m7_dout_tdata)    // output wire [63 : 0]    m_axis_dout_tdata
    );

    CEST_DIVIDER3 U_CEST_DIVIDER3 (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s8_divisor_tvalid),    // input wire     s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s8_divisor_tdata),      // input wire [15 : 0]    s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s8_dividend_tvalid),  // input wire     s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s8_dividend_tdata),    // input wire [31 : 0]    s_axis_dividend_tdata
        .m_axis_dout_tvalid(m8_dout_tvalid),          // output wire    m_axis_dout_tvalid
        .m_axis_dout_tdata(m8_dout_tdata)            // output wire [47 : 0] m_axis_dout_tdata
    );

    //% calculate the average of H~
    AVEH U_AVEH (
        .clk(clk),
        .rst(rst),
        .din_re(H_re),
        .din_im(H_im),
        .din_vld(H_vld),
        .dout_re(H_estimated_re),
        .dout_im(H_estimated_im),
        .dout_vld(H_estimated_vld)
    );

    //% calculate the average of N
    AVEN U_AVEN (
        .clk(clk),
        .rst(rst),
        .din(noise_power_scaled),
        .din_vld(noise_power_scaled_vld),
        .dout(sigma2),
        .dout_vld(sigma2_vld)
    );

endmodule
