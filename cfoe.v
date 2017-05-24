//% @file cfoe.v
//% @brief Implementation file of Carrier Frequency Offset Estimation(CFOE) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-01

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Carrier Frequency Offset Estimation(CFOE) finish the Estimation using a 
//% CORDIC IP core.
//% 
//% **Timing**
//% 
//% 1. delay the input data to the output port using a LSR
//% 2. select the 2*N samples from the packet_start index, calculate the correlation
//% 3. get the estimated of frequency offset using a CORDIC IP core
//% 
//% @note The output cfo_estimated's format is 2Q15: 1(sign) + 2 integer + 15 fraction.
//        In the test, cfo_estimated = 1.5638 (variable "tmp" in c cdoe), have different
//        format with vs fix point project(the same value).
module CFOE (
    input                        clk,               //% working clock
    input                        rst,               //% synchronous reset, active high
    input        signed  [11:0]  di_re,             //% received data, real part
    input        signed  [11:0]  di_im,             //% received data, image part
    input                        packet_start,      //% start point of packet detect
    output  reg  signed  [11:0]  do_re,             //% output data, real part
    output  reg  signed  [11:0]  do_im,             //% output data, image part
    output  reg                  cs_start,          //% compensate & symbol sync start flag
    output  reg  signed  [17:0]  cfo_estimated,     //% estimated frequency offset
    output  reg                  cfo_estimated_vld  //% estimated cfo valid flag
    );

//==============================================================================
// Main Body of Code
    reg  done_flag;				//Modified by baiyf
	 reg  done_rst;
    //--------------------------------------------------------------------------
    // select the samples later to packet_start

    localparam      CNT_MAX  = 3 * `N - 1;      //% max vaule of cnt 
    localparam      CNT_HALF = 2 * `N - 1;      //% half value of cnt
    reg    cnt_en;     //% counter enable flag
    //% enable the counter when detect a new frame, and disable it when reach
    //% the max value of counter
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cnt_en <= 0;
        end
        else begin
            if (packet_start) begin
                cnt_en <= 1;
            end
            if (cnt == CNT_MAX) begin
                cnt_en <= 0;
            end
        end
    end

    reg  [10:0]  cnt;    //% counter to find the point later to packet_start
    integer  cnt_flag;
	 //% find the pointer later to packet_start
	 
	 always @(posedge clk or posedge rst or posedge done_rst) begin					//	Modified by baiyf
		if(rst||done_rst) begin
			cnt_flag <= 0;
		end
		else begin
			cnt_flag <= cnt_flag +1;
		end
	 end
	 
	 always @(posedge clk or posedge rst or posedge done_rst) begin					//Modified by baiyf	
		if(rst||done_rst) begin
			done_flag <= 0;
		end
		else begin
			if(cnt_flag == 8912) begin
				done_flag <= 1;
			end
		end
	 end
	 
	 always @(posedge clk ) begin																	//Modified by baiyf
	     if(done_flag ) begin
		      done_rst <= 1;
		  end
		  else begin
		      done_rst <= 0;
		  end
	 end
	 
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (cnt == CNT_MAX) begin
                cnt <= 0;
            end
            else if (cnt_en) begin
                cnt <= cnt + 1;
            end
            else begin
                cnt <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // calcualte the 2*N input data's correlation

    wire  signed  [11:0]  data_re;      //% output of Shift Reg, real part
    wire  signed  [11:0]  data_im;      //% output of Shift Reg, image part

    reg   signed  [31:0]  s_a_tdata;    //% complex multiplier input channel a
    reg   signed  [31:0]  s_b_tdata;    //% complex multiplier input channel b
    //% generate the input data to complex mulitplier (AXI4 BUS format)
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s_a_tdata <= 0;
            s_b_tdata <= 0;
        end
        else begin
            s_a_tdata <= {4'b0, di_im, 4'b0, di_re};
            s_b_tdata <= {4'b0, -data_im, 4'b0, data_re};
        end
    end

    reg         s_a_tvalid;     //% channel a data valid flag
    reg         s_b_tvalid;     //% channel b data valid flag
    //% set the value of s_a_tvalid & s_b_tvalid
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s_a_tvalid <= 0;
            s_b_tvalid <= 0;
        end
        else begin
            if (cnt == CNT_HALF) begin
                s_a_tvalid <= 1;
                s_b_tvalid <= 1;
            end
            else if (cnt == CNT_MAX) begin
                s_a_tvalid <= 0;
                s_b_tvalid <= 0;
            end
        end
    end

    wire  signed  [63:0]  m_dout_tdata;     //% output of multiplier
    wire                  m_dout_tvalid;    //% valid flag of multiplier output

    reg   signed  [24:0]  corr_re;      //% real part of correlation
    reg   signed  [24:0]  corr_im;      //% image part of correlation
    //% get the real & image part of correlation
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            corr_re <= 0;
            corr_im <= 0;
        end
        else begin
            corr_re <= m_dout_tdata[24: 0];
            corr_im <= m_dout_tdata[56:32];
        end
    end

    // bit increase, 512 samples accumulate, increase 9 bits
    reg  signed  [33:0]     sum_corr_re;    //% sum of corr_re
    reg  signed  [33:0]     sum_corr_im;    //% sum of corr_im
    //% accumulate the corr_re & corr_im (N samples)
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            sum_corr_re <= 0;
            sum_corr_im <= 0;
        end
        else begin
            if (m_dout_tvalid) begin
                sum_corr_re <= sum_corr_re + {{9{corr_re[24]}}, corr_re};
                sum_corr_im <= sum_corr_im + {{9{corr_im[24]}}, corr_im};
            end
        end
    end

    //--------------------------------------------------------------------------
    // calculate the atan(re, im) using CORDIC

    reg  [4:0]  cnt2;       //% counter used to get the valid sum_corr_re/im
    reg         cnt2_en;    //% cnt2 enable flag
    //% complex multiplier's latency is 6 clock period, so using a counter get
    //% the final sum_corr_re & sum_corr_im
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cnt2_en <= 0;
        end
        else begin
            if (cnt == CNT_MAX) begin
                cnt2_en <= 1;
            end
            else if (cnt2 == 10) begin
                cnt2_en <= 0;
            end
        end
    end

    //% increase cnt2 when it is enabled
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cnt2 <= 0;
        end
        else begin
            if (cnt2_en) begin
                cnt2 <= cnt2 + 1;
            end
            else begin
                cnt2 <= 0;
            end
        end
    end

    reg     s_catesian_tvalid;  //% Cordic input data valid flag
    wire    s_cartesian_tready; //% Cordic IP core is ready to recevie input data
    //% when sum_corr_re/im is valid, set the valid flag
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s_catesian_tvalid <= 0;
        end
        else begin
            if (cnt2 == 10) begin
                s_catesian_tvalid <= 1;
            end
            else if (s_cartesian_tready) begin
                s_catesian_tvalid <= 0;
            end
        end
    end

    reg     [79:0]  s_cartesian_tdata;  //% input data to cordic core
    //% set the value of s_cartesian_tdata
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            s_cartesian_tdata <= 0;
        end
        else begin
            s_cartesian_tdata <= {6'b0, sum_corr_im, 6'b0, sum_corr_re};
        end
    end

    //-------------------------------------------------------------------------
    // generate the output

    //% generate the start point flag for CFOC & SSYNC
    always @(posedge clk or posedge rst or posedge done_rst) begin
         if (rst||done_rst) begin
             // reset
             cs_start <= 0;
         end
         else begin
            // align the cs_start with do_re/im, because output is from the LSR,
            // so the CNT_HALF should more N samples(2N-1, rather than N-1)
             if (cnt == CNT_HALF) begin
                 cs_start <= 1;
             end
             else begin
                 cs_start <= 0;
             end
         end
     end

    //% generat the output data
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
        end
        else begin
            do_re <= data_re;
            do_im <= data_im;
        end
    end

    wire          m_atan_dout_tvalid;   //% cordic core output valid flag
    wire  [23:0]  m_atan_dout_tdata;    //% cordic core output data
    //% output the cordic core's result
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cfo_estimated <= 0;
        end
        else begin
           if (m_atan_dout_tvalid) begin
               cfo_estimated <= m_atan_dout_tdata[17:0];
           end
        end
    end

    //% set the output valid flag
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            cfo_estimated_vld <= 0;
        end
        else begin
            cfo_estimated_vld <= m_atan_dout_tvalid;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate 1 RAM-based Shift Reg IP core

    CFOE_SHIFT_REG_RE U_CFOE_SHIFT_REG_RE (
        .d(di_re),      // input wire [11 : 0] D
        .clk(clk),  // input wire CLK
        .q(data_re)      // output wire [11 : 0] Q
    );

    CFOE_SHIFT_REG_IM U_CFOE_SHIFT_REG_IM (
        .d(di_im),      // input wire [11 : 0] D
        .clk(clk),  // input wire CLK
        .q(data_im)      // output wire [11 : 0] Q
    );

    //--------------------------------------------------------------------------
    // instantiate the complex multiplier IP core

    CFOE_CORR U_CFOE_CORR (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(m_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    //--------------------------------------------------------------------------
    // instantiate the CORDIC IP core

    CORDIC_ATAN U_CORDIC_ATAN (
        .aclk(clk),                                        // input wire aclk
        .s_axis_cartesian_tvalid(s_catesian_tvalid),  // input wire s_axis_cartesian_tvalid
        .s_axis_cartesian_tready(s_cartesian_tready),  // output wire s_axis_cartesian_tready
        .s_axis_cartesian_tdata(s_cartesian_tdata),    // input wire [79 : 0] s_axis_cartesian_tdata
        .m_axis_dout_tvalid(m_atan_dout_tvalid),            // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_atan_dout_tdata)              // output wire [23 : 0] m_axis_dout_tdata
    );

endmodule