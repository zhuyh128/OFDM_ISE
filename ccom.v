//% @file ccom.v
//% @brief Implementation file of Channel Compensation Unit(CCOM) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-24

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Channel Compensation Unit(CCOM) finish the channel compensation for 
//% received signal & payload.
//%
//% **Theory:**
//% 
//% R~ = R/H~ = L
//% 
//% @note input*1578 first!
module CCOM (
    input                        clk,        //% working clock
    input                        rst,        //% synchronous reset, active high
    input        signed  [11:0]  din_sp_re,  //% input real signal & payload
    input        signed  [11:0]  din_sp_im,  //% input image signal & payload
    input                        din_sp_vld, //% din_sp_re/im valid flag
    input        signed  [11:0]  din_H_re,   //% input estimated real H
    input        signed  [11:0]  din_H_im,   //% input estimated iamge H
    input                        din_H_vld,  //% din_H_re/im valid flag
    output  reg  signed  [11:0]  dout_re,    //% compensated real s & p
    output  reg  signed  [11:0]  dout_im,    //% compensated image s & p
    output  reg                  dout_vld    //% dout_re/im valid flag
    );

//=============================================================================
// Main Body of Code

    //-------------------------------------------------------------------------
    // 1st. save input signal & payload symbols into a FIFO

    //---------------------------
    // real part
    wire                  sp_re_full;
    reg                   sp_re_wr_en;
    reg   signed  [11:0]  sp_re_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sp_re_wr_en <= 0;
            sp_re_din <= 0;
        end
        else begin
            if (!sp_re_full && din_sp_vld) begin
                sp_re_wr_en <= 1;
            end
            else begin
                sp_re_wr_en <= 0;
            end
            sp_re_din <= din_sp_re;
        end
    end

    //---------------------------
    // image part
    wire                  sp_im_full;
    reg                   sp_im_wr_en;
    reg   signed  [11:0]  sp_im_din;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sp_im_wr_en <= 0;
            sp_im_din <= 0;
        end
        else begin
            if (!sp_im_full && din_sp_vld) begin
                sp_im_wr_en <= 1;
            end
            else begin
                sp_im_wr_en <= 0;
            end
            sp_im_din <= din_sp_im;
        end
    end

    //-------------------------------------------------------------------------
    // 2nd. save input H into a RAM

    //---------------------------
    // real part
    reg                  H_re_wea;
    reg          [8 :0]  H_re_addra;
    reg  signed  [11:0]  H_re_dina;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_re_wea <= 0;
            H_re_addra <= 9'b1_1111_1111;
            H_re_dina <= 0;
        end
        else begin
            H_re_wea <= din_H_vld;
            if (din_H_vld) begin
                H_re_addra <= H_re_addra + 1;
            end
            H_re_dina <= din_H_re;
        end
    end

    //---------------------------
    // image part
    reg                  H_im_wea;
    reg          [8 :0]  H_im_addra;
    reg  signed  [11:0]  H_im_dina;

        always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_im_wea <= 0;
            H_im_addra <= 9'b1_1111_1111;
            H_im_dina <= 0;
        end
        else begin
            H_im_wea <= din_H_vld;
            if (din_H_vld) begin
                H_im_addra <= H_im_addra + 1;
            end
            H_im_dina <= din_H_im;
        end
    end

    //-------------------------------------------------------------------------
    // 3rd. read out signal & payload, H
    
    localparam   WR_CNT_MAX = `N;     // CEST's output is later than SPFFT
    reg  [12:0]  wr_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX) begin
                wr_cnt <= WR_CNT_MAX;
            end
            else if (din_H_vld) begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end

    //-----------------------------------
    // read signal & payload

    wire                  sp_re_empty;
    reg                   sp_re_rd_en;
    wire  signed  [11:0]  sp_re_dout;
    wire                  sp_re_valid;

    wire                  sp_im_empty;
    reg                   sp_im_rd_en;
    wire  signed  [11:0]  sp_im_dout;
    wire                  sp_im_valid;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sp_re_rd_en <= 0;
            sp_im_rd_en <= 0;
        end
        else begin
            if (!sp_re_empty && wr_cnt == WR_CNT_MAX) begin
                sp_re_rd_en <= 1;
            end
            else begin
                sp_re_rd_en <= 0;
            end
            if (!sp_im_empty && wr_cnt == WR_CNT_MAX) begin
                sp_im_rd_en <= 1;
            end
            else begin
                sp_im_rd_en <= 0;
            end
        end
    end

    //-----------------------------------
    // read H
    
    reg           [8 :0]  H_re_addrb;
    wire  signed  [11:0]  H_re_doutb;

    reg           [8 :0]  H_im_addrb;
    wire  signed  [11:0]  H_im_doutb;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            H_re_addrb <= 9'b1_1111_1111;
            H_im_addrb <= 9'b1_1111_1111;
        end
        else begin
            if (sp_re_rd_en) begin
                H_re_addrb <= H_re_addrb + 1;
                H_im_addrb <= H_im_addrb + 1;
            end
            else begin
                H_re_addrb <= 9'b1_1111_1111;
                H_im_addrb <= 9'b1_1111_1111;
            end
        end
    end

    //-------------------------------------------------------------------------
    // 4th. calculate R~ = R/H~

    // aligin the R & H~

    wire  signed  [11:0]  sp_re_dout_dly1;
    wire  signed  [11:0]  sp_im_dout_dly1;
    wire                  sp_vld_dly1;

    DLY1 #(.WIDTH(1)) u_sp_vld_dly1 (
        .clk(clk),
        .rst(rst),
        .din(sp_re_valid),
        .dout(sp_vld_dly1)
    );

    DLY1 #(.WIDTH(12)) u_sp_re_dly1 (
        .clk(clk),
        .rst(rst),
        .din(sp_re_dout),
        .dout(sp_re_dout_dly1)
    );

    DLY1 #(.WIDTH(12)) u_sp_im_dly1 (
        .clk(clk),
        .rst(rst),
        .din(sp_im_dout),
        .dout(sp_im_dout_dly1)
    );

    //--------------------------------------
    // R/H~ = (a+b*j)/(c+d*j) = (a+b*j)(c-d*j) / (c+d*j)(c-d*j)

    // (a+b*j)(c-d*j)
    reg          s1_a_tvalid;
    reg  [31:0]  s1_a_tdata;

    reg          s1_b_tvalid;
    reg  [31:0]  s1_b_tdata;

    wire         m1_dout_tvalid;
    wire [63:0]  m1_dout_tdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s1_a_tvalid <= 0;
            s1_a_tdata <= 0;
            s1_b_tvalid <= 0;
            s1_b_tdata <= 0;
        end
        else begin
            s1_a_tvalid <= sp_vld_dly1;
            s1_a_tdata <= {4'b0, sp_im_dout_dly1, 4'b0, sp_re_dout_dly1};
            s1_b_tvalid <= sp_vld_dly1;
            s1_b_tdata <= {4'b0, -H_im_doutb, 4'b0, H_re_doutb};
        end
    end

    // (c+d*j)(c-d*j)
    reg          s2_a_tvalid;
    reg  [31:0]  s2_a_tdata;

    reg          s2_b_tvalid;
    reg  [31:0]  s2_b_tdata;

    wire         m2_dout_tvalid;
    wire [63:0]  m2_dout_tdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s2_a_tvalid <= 0;
            s2_a_tdata <= 0;
            s2_b_tvalid <= 0;
            s2_b_tdata <= 0;
        end
        else begin
            s2_a_tvalid <= sp_vld_dly1;
            s2_a_tdata <= {4'b0, H_im_doutb, 4'b0, H_re_doutb};
            s2_b_tvalid <= sp_vld_dly1;
            s2_b_tdata <= {4'b0, -H_im_doutb, 4'b0, H_re_doutb};
        end
    end

    //-------------------------------
    
    // fix the width
    reg  signed  [24:0]  A1;
    reg  signed  [24:0]  A2;
    wire signed  [11:0]  B;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            A1 <= 0;
            A2 <= 0;
        end
        else begin
            A1 <= m1_dout_tdata[24: 0];
            A2 <= m1_dout_tdata[56:32];
        end
    end

    assign B = 12'd1578;

    wire  signed  [36:0]  dividend_re;
    wire  signed  [36:0]  dividend_im;

    reg                  divisor_pre_vld;
    reg  signed  [24:0]  divisor_pre;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            divisor_pre_vld <= 0;
            divisor_pre <= 0;
        end
        else begin
            divisor_pre_vld <= m2_dout_tvalid;
            divisor_pre <= m2_dout_tdata[24: 0];
        end
    end

    // align the dividend & dvisor

    wire                  divisor_vld;
    wire  signed  [24:0]  divisor;

    DLY3 #(.WIDTH(1)) u_divisor_vld_dly3 (
        .clk(clk),
        .rst(rst),
        .din(divisor_pre_vld),
        .dout(divisor_vld)
    );

    DLY3 #(.WIDTH(25)) u_divisor_dly3 (
        .clk(clk),
        .rst(rst),
        .din(divisor_pre),
        .dout(divisor)
    );

    //-----------------------------------------
    // divide, real part

    reg          s3_divisor_tvalid;
    reg  [31:0]  s3_divisor_tdata;
    reg          s3_dividend_tvalid;
    reg  [39:0]  s3_dividend_tdata;

    wire         m3_dout_tvalid;
    wire [71:0]  m3_dout_tdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s3_divisor_tvalid <= 0;
            s3_divisor_tdata <= 0;
            s3_dividend_tvalid <= 0;
            s3_dividend_tdata <= 0;
        end
        else begin
            s3_divisor_tvalid <= divisor_vld;
            s3_divisor_tdata <= {7'b0, divisor};
            s3_dividend_tvalid <= divisor_vld;
            s3_dividend_tdata <= {3'b0, dividend_re};
        end
    end

    //-----------------------------------------
    // divide, image part

    reg          s4_divisor_tvalid;
    reg  [31:0]  s4_divisor_tdata;
    reg          s4_dividend_tvalid;
    reg  [39:0]  s4_dividend_tdata;

    wire         m4_dout_tvalid;
    wire [71:0]  m4_dout_tdata;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s4_divisor_tvalid <= 0;
            s4_divisor_tdata <= 0;
            s4_dividend_tvalid <= 0;
            s4_dividend_tdata <= 0;
        end
        else begin
            s4_divisor_tvalid <= divisor_vld;
            s4_divisor_tdata <= {7'b0, divisor};
            s4_dividend_tvalid <= divisor_vld;
            s4_dividend_tdata <= {3'b0, dividend_im};
        end
    end

    //-------------------------------------------------------------------------
    // output the result

    reg  signed  [36:0]  quotient_re;
    reg  signed  [36:0]  quotient_im;
    reg                  quotient_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            quotient_re <= 0;
            quotient_im <= 0;
            quotient_vld <= 0;
        end
        else begin
            quotient_re <= m3_dout_tdata[68:32];
            quotient_im <= m4_dout_tdata[68:32];
            quotient_vld <= m3_dout_tvalid;
        end
    end

    // saturation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_vld <= 0;
            dout_re <= 0;
            dout_im <= 0;
        end
        else begin
            dout_vld <= quotient_vld;
            // do_re
            if (quotient_re > 2047) begin
                dout_re <= 2047;
            end
            else if (quotient_re < -2048) begin
                dout_re <= -2048;
            end
            else begin
                dout_re <= quotient_re[11:0];
            end
            if (quotient_im > 2047) begin
                dout_im <= 2047;
            end
            else if (quotient_im < -2048) begin
                dout_im <= -2048;
            end
            else begin
                dout_im <= quotient_im[11:0];
            end
        end
    end

    //-------------------------------------------------------------------------
    // instantiate IP cores

    CCOM_SP_RE U_CCOM_SP_RE (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(sp_re_din),      // input wire [11 : 0] din
        .wr_en(sp_re_wr_en),  // input wire wr_en
        .rd_en(sp_re_rd_en),  // input wire rd_en
        .dout(sp_re_dout),    // output wire [11 : 0] dout
        .full(sp_re_full),    // output wire full
        .empty(sp_re_empty),  // output wire empty
        .valid(sp_re_valid)  // output wire valid
    );

    CCOM_SP_IM U_CCOM_SP_IM (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(sp_im_din),      // input wire [11 : 0] din
        .wr_en(sp_im_wr_en),  // input wire wr_en
        .rd_en(sp_im_rd_en),  // input wire rd_en
        .dout(sp_im_dout),    // output wire [11 : 0] dout
        .full(sp_im_full),    // output wire full
        .empty(sp_im_empty),  // output wire empty
        .valid(sp_im_valid)  // output wire valid
    );

    CCOM_H_RE U_CCOM_H_RE (
        .clka(clk),    // input wire clka
        .wea(H_re_wea),      // input wire [0 : 0] wea
        .addra(H_re_addra),  // input wire [8 : 0] addra
        .dina(H_re_dina),    // input wire [11 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(H_re_addrb),  // input wire [8 : 0] addrb
        .doutb(H_re_doutb)  // output wire [11 : 0] doutb
    );

    CCOM_H_IM U_CCOM_H_IM (
        .clka(clk),    // input wire clka
        .wea(H_im_wea),      // input wire [0 : 0] wea
        .addra(H_im_addra),  // input wire [8 : 0] addra
        .dina(H_im_dina),    // input wire [11 : 0] dina
        .clkb(clk),    // input wire clkb
        .addrb(H_im_addrb),  // input wire [8 : 0] addrb
        .doutb(H_im_doutb)  // output wire [11 : 0] doutb
    );

    CCOM_MUL1 U_CCOM_MUL1 (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s1_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s1_a_tdata),          // input wire [31 : 0]    s_axis_a_tdata
        .s_axis_b_tvalid(s1_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s1_b_tdata),          // input wire [31 : 0]    s_axis_b_tdata
        .m_axis_dout_tvalid(m1_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m1_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    CCOM_MUL2 U_CCOM_MUL2 (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s2_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s2_a_tdata),          // input wire [31 : 0]    s_axis_a_tdata
        .s_axis_b_tvalid(s2_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s2_b_tdata),          // input wire [31 : 0]    s_axis_b_tdata
        .m_axis_dout_tvalid(m2_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m2_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    CCOM_MUL3 U_CCOM_MUL3 (
        .clk(clk),  // input wire CLK
        .a(A1),      // input wire [24 : 0] A
        .b(B),      // input wire [11 : 0] B
        .p(dividend_re)      // output wire [36 : 0] P
    );

    CCOM_MUL4 U_CCOM_MUL4 (
        .clk(clk),  // input wire CLK
        .a(A2),      // input wire [24 : 0] A
        .b(B),      // input wire [11 : 0] B
        .p(dividend_im)      // output wire [36 : 0] P
    );

    CCOM_DIV_RE U_CCOM_DIV_RE (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s3_divisor_tvalid),    // input wire     s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s3_divisor_tdata),      // input wire [31 : 0]    s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s3_dividend_tvalid),  // input wire     s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s3_dividend_tdata),    // input wire [39 : 0]    s_axis_dividend_tdata
        .m_axis_dout_tvalid(m3_dout_tvalid),          // output wire    m_axis_dout_tvalid
        .m_axis_dout_tdata(m3_dout_tdata)            // output wire [71 : 0] m_axis_dout_tdata
    );

    CCOM_DIV_IM U_CCOM_DIV_IM (
        .aclk(clk),                                      // input wire aclk
        .s_axis_divisor_tvalid(s4_divisor_tvalid),    // input wire     s_axis_divisor_tvalid
        .s_axis_divisor_tdata(s4_divisor_tdata),      // input wire [31 : 0]    s_axis_divisor_tdata
        .s_axis_dividend_tvalid(s4_dividend_tvalid),  // input wire     s_axis_dividend_tvalid
        .s_axis_dividend_tdata(s4_dividend_tdata),    // input wire [39 : 0]    s_axis_dividend_tdata
        .m_axis_dout_tvalid(m4_dout_tvalid),          // output wire    m_axis_dout_tvalid
        .m_axis_dout_tdata(m4_dout_tdata)            // output wire [71 : 0] m_axis_dout_tdata
    );

endmodule