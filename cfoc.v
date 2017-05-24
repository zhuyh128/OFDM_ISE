//% @file cfoc.v
//% @brief Implementation file of Carrier Frequency Offset Compensation(CFOC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-02

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Carrier Frequency Offset Compensation(CFOC) finish the compensation for CFO.
//% 
//% **Timing**
//% 
//% 1. using a fifo to buffer the input data
//% 2. when input cfo_estimated is valid, calcute the sin(theta) & cos(theta)
//% 3. align the sin(theta) & cos(theta) with fifo output
//% 4. compensate the fifo output using sin(theta), cos(theta)
//% 
//% @note using a big FIFO because the read operation is slower than write operation.
//%       preamble: 512*8; signal+paylaod: (512+32)*10 = 5440, total = 9536. the
//%       depth of the FIFO >= 9536
//% @note data has a valid flag since this module. Becase this module use a FIFO(depth=9536)
//%       to store input data, so the length of output valid data is 9536. The RAMs in
//%       downstream logic(DSEP module) is depended on it.
module CFOC (
    input                        clk,               //% working clock
    input                        rst,               //% synchronous reset, active high
    input        signed  [11:0]  di_re,             //% data to be compensated, real part
    input        signed  [11:0]  di_im,             //% data to be compensated, image part
    input                        cs_start,          //% compensate & symbol sync start flag
    input        signed  [17:0]  cfo_estimated,     //% estimated cfo
    input                        cfo_estimated_vld, //% estimated cfo valid flag
    output  reg  signed  [11:0]  do_re,             //% compensated data, real part
    output  reg  signed  [11:0]  do_im,             //% compensated data, image part
    output  reg                  do_vld             //% compensated data valid flag
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // write data into fifo

    reg  [23:0]  din;   //% data into fifo
    //% generate the data{di_im, di_re} into fifo
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din <= 0;
        end
        else begin
            din <= {di_im, di_re};
        end
    end

    reg  [13:0]  wr_cnt;
    reg     wr_en;      //% fifo write enable
    wire    full;       //% fifo full flag

    localparam      WR_CNT_MAX = 9536;  // 8 preamble symbol + 10 {signal + payload}
                                        // 8*512 + (512+32)*10 = 9536

    //% enable write when received valid preamble data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
        end
        else begin
            if (cs_start) begin
                wr_en <= 1;
            end
            else if (full || wr_cnt == WR_CNT_MAX) begin
                wr_en <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_cnt <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX) begin
                wr_cnt <= WR_CNT_MAX;
            end
            else if (wr_en) begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // calculate the compensation value

    reg  signed  [17:0]  cfo;   //% local tmp
    //% calculate cfo
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cfo <= 0;
        end
        else begin
            if (cfo_estimated_vld) begin
                cfo <= {{9{cfo_estimated[17]}}, cfo_estimated[17:9]};  // cfo = cfo_estimated / N
            end
        end
    end

    reg     theta_en;   //% when input is valid, enable the cordic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            theta_en <= 0;
        end
        else begin
            if (cfo_estimated_vld) begin
                theta_en <= 1;
            end
        end
    end

    reg  signed  [18:0]  theta_pre; //% local tmp
    reg  signed  [17:0]  theta;     //% final theta
    //% calculate theta_pre
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            theta_pre <= 0;
        end
        else begin
            if (theta_en) begin
                theta_pre <= theta + cfo;
            end
        end
    end

    reg  signed  [18:0]  PI_A = 19'b0_011_0010_0011_1101_000;    //% +pi in 2Q15 format
    reg  signed  [18:0]  PI_B = 19'b1_100_1101_1100_0011_000;    //% -pi in 2Q15 format
    reg  signed  [18:0]  PI_C = 19'b0_110_0100_0111_1010_100;    //% 2*pi in 2Q15 format

    reg  signed  [18:0]  theta_wrap;    //% cordic core requires -pi < input < pi
    //% wrap the theta into [-pi, pi]
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            theta_wrap <= 0;
        end
        else begin
            // cordic core require the -pi < theta < pi
            if (theta_pre > PI_A) begin
                theta_wrap <= theta_pre - PI_C;
            end
            else if (theta < PI_B) begin
                theta_wrap <= theta_pre + PI_C;
            end
            else begin
                theta_wrap <= theta_pre;
            end
        end
    end

    //% get the final theta
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            theta <= 0;
        end
        else begin
            theta <= theta_wrap[17:0];
        end
    end

    reg     s_phase_tvalid;     //% theta into core valid flag
    //% set theta valid flag
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_phase_tvalid <= 0;
        end
        else begin
            s_phase_tvalid <= theta_en;
        end
    end

    reg  [23:0]  s_phase_tdata; //% input to cordic core
    //% cope the theta into cordic core
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_phase_tdata <= 0;
        end
        else begin
            s_phase_tdata <= {6'b0, theta};
        end
    end

    wire  [31:0]  m_dout_tdata;     //% cordic core output
    wire          m_dout_tvalid;    //% cordic core output valid
    reg  signed  [11:0]  cos;       //% cos(theta), 1Q10 format
    reg  signed  [11:0]  sin;       //% sin(theta)
    //% get sin & cos from cordic output result
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cos <= 0;
            sin <= 0;
        end
        else begin
            cos <= m_dout_tdata[11: 0];
            sin <= m_dout_tdata[27:16];
        end
    end

    //--------------------------------------------------------------------------
    // read fifo

    localparam   RD_CNT_MAX = 2;

    reg          rd_cnt_en;  //% fifo read counter enable
    reg  [1:0]   rd_cnt;     //% fifo read counter, the sin(theta) is valid every
                             //% 3 clock, so use a counter to align the sin(cos)
                             //% with fifo output
    //% enable read opration when get the valid estimation of CFO
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_cnt_en <= 0;
        end
        else begin
            if (m_dout_tvalid) begin
                rd_cnt_en <= 1;
            end
            else begin
                rd_cnt_en <= 0;
            end
        end
    end

    //% start read counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_cnt <= 0;
        end
        else begin
            if (rd_cnt_en) begin
                if (rd_cnt == RD_CNT_MAX) begin
                    rd_cnt <= 0;
                end
                else begin
                    rd_cnt <= rd_cnt + 1;
                end
            end
            else begin
                rd_cnt <= 0;
            end
        end
    end

    wire    empty;  //% fifo empty flag
    reg     rd_en;  //% fifo read enable
    //% when fifo is not empty, every 3 clock output one data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (rd_cnt == 2'b1 && !empty) begin
                rd_en <= 1;
            end
            else begin
                rd_en <= 0;
            end
        end
    end

    wire  [23:0]  dout;     //% fifo output {data_im, data_re}
    wire          valid;    //% fifo output valid flag

    reg   signed  [11:0]  data_re;  //% data to be compensated, real part
    reg   signed  [11:0]  data_im;  //% data to be compensated, image part
    //% get data_re/im from fifo output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data_re <= 0;
            data_im <= 0;
        end
        else  begin
            data_re <= dout[11: 0];
            data_im <= dout[23:12];
        end
    end

    reg         data_vld;   //% data_re/im valid flag
    //% align the data_re/im with valid flag
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data_vld <= 0;
        end
        else begin
            data_vld <= valid;
        end
    end

    //% align the cos/sin to data_re/im
    reg  signed  [11:0]  cos_r1;    //% local tmp to align cos with data_re/im
    reg  signed  [11:0]  cos_r2;    //% local tmp to align cos with data_re/im
    reg  signed  [11:0]  cos_r3;    //% local tmp to align cos with data_re/im
    reg  signed  [11:0]  cos_r4;    //% local tmp to align cos with data_re/im
    reg  signed  [11:0]  cos_r5;    //% local tmp to align cos with data_re/im

    reg  signed  [11:0]  sin_r1;    //% local tmp to align sin with data_re/im
    reg  signed  [11:0]  sin_r2;    //% local tmp to align sin with data_re/im
    reg  signed  [11:0]  sin_r3;    //% local tmp to align sin with data_re/im
    reg  signed  [11:0]  sin_r4;    //% local tmp to align sin with data_re/im
    reg  signed  [11:0]  sin_r5;    //% local tmp to align sin with data_re/im

    //% align the cos with data_re/im
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cos_r1 <= 0;
            cos_r2 <= 0;
            cos_r3 <= 0;
            cos_r4 <= 0;
            cos_r5 <= 0;
        end
        else begin
            cos_r1 <= cos;
            cos_r2 <= cos_r1;
            cos_r3 <= cos_r2;
            cos_r4 <= cos_r3;
            cos_r5 <= cos_r4;
        end
    end

    //% align the sin with data_re/im
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sin_r1 <= 0;
            sin_r2 <= 0;
            sin_r3 <= 0;
            sin_r4 <= 0;
            sin_r5 <= 0;
        end
        else begin
            sin_r1 <= sin;
            sin_r2 <= sin_r1;
            sin_r3 <= sin_r2;
            sin_r4 <= sin_r3;
            sin_r5 <= sin_r4;
        end
    end

    //--------------------------------------------------------------------------
    // compensation

    reg          s_a_tvalid;    //% channel a's input data valid flag
    reg          s_b_tvalid;    //% channel b's input data valid flag
    reg  [31:0]  s_a_tdata;     //% channel a's input data
    reg  [31:0]  s_b_tdata;     //% channel b's input data

    //% set channel a & b's input valid flag
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_a_tvalid <= 0;
            s_b_tvalid <= 0;
        end
        else begin
            s_a_tvalid <= data_vld;
            s_b_tvalid <= data_vld;
        end
    end

    //% generate the channel a & b's input data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_a_tdata <= 0;
            s_b_tdata <= 0;
        end
        else begin
            s_a_tdata <= {4'b0, data_im, 4'b0, data_re};
            s_b_tdata <= {4'b0, -sin_r5, 4'b0, cos_r5};
        end
    end

    wire  signed  [63:0]  m_mul_dout_tdata;     //% complex multiplier output
    wire                  m_mul_dout_tvalid;    //% complex multiplier output valid flag

    // get compensated output from complex multiplier output
    // because the format of sin, cos is 1Q10, right shift 10 bits 
    // to get the compensation result.
    reg  signed  [14:0]  mult_out_re;
    reg  signed  [14:0]  mult_out_im;
    reg                  mult_out_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            mult_out_re <= 0;
            mult_out_im <= 0;
            mult_out_vld <= 0;
        end
        else begin
            mult_out_re <= m_mul_dout_tdata[24:10];
            mult_out_im <= m_mul_dout_tdata[56:42];
            mult_out_vld <= m_mul_dout_tvalid;
        end
    end

    // saturation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re <= 0;
            do_im <= 0;
            do_vld <= 0;
        end
        else begin
            // do_re
            if (mult_out_re > 2047) begin
                do_re <= 2047;
            end
            else if (mult_out_re < -2048) begin
                do_re <= -2048;
            end
            else begin
                do_re <= mult_out_re;
            end
            // do_im
            if (mult_out_im > 2047) begin
                do_im <= 2047;
            end
            else if (mult_out_im < -2048) begin
                do_im <= -2048;
            end
            else begin
                do_im <= mult_out_im;
            end
            // do_vld
            do_vld <= mult_out_vld;
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the FIFO core

    //% FIFO core to buffer input data
    CFOC_FIFO U_CFOC_FIFO (
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

    //% CORDIC core to calculate sin(theta) & cos(theta)
    CFOC_CORDIC_SIN_COS U_CFOC_CORDIC_SIN_COS (
        .aclk(clk),                                // input wire aclk
        .s_axis_phase_tvalid(s_phase_tvalid),  // input wire s_axis_phase_tvalid
        .s_axis_phase_tdata(s_phase_tdata),    // input wire [23 : 0] s_axis_phase_tdata
        .m_axis_dout_tvalid(m_dout_tvalid),    // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_dout_tdata)      // output wire [31 : 0] m_axis_dout_tdata
    );

    //% Complex Multiplier to get the final compensated data
    CFOC_MULTIPLIER U_CFOC_MULTIPLIER (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(m_mul_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_mul_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

endmodule