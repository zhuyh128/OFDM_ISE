//% @file ssync.v
//% @brief Implementation file of Symbol Synchronizer(SSYNC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-04

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Symbol Synchronizer(SSYNC) finish the symbol synchronization for received data.
//% 
//% **Timing**
//% 
//% 1. input data is the cfo compensated data, using the first N samples
//% 2. FFT(input)
//% 3. corr = FFT(input) * conj(local)
//% 4. freq = IFFT(corr)
//% 5. max index = arg{max(freq)}
//% 
//% @note the FFT core radix-4 burst I/O, non real time mode, using a FIFO save 
//%       the input data first.
//% @note after each frame, must reset the receiver
module SSYNC (
    input                        clk,           //% working clock
    input                        rst,           //% synchronous reset, active high
    input        signed  [11:0]  di_re,         //% input compensated data, real part
    input        signed  [11:0]  di_im,         //% input compensated data, image part
    input                        di_vld,        //% input data valid flag
    output  reg  signed  [11:0]  do_re,         //% output data, real part
    output  reg  signed  [11:0]  do_im,         //% output data, image part
    output  reg                  do_vld,        //% output data valid flag
    output  reg          [9 :0]  max_indx,      //% result of synchronization
                                                //% the start point of signal segment
    output  reg                  max_indx_vld   //% max_indx valid flag
    );

//==============================================================================
// Main Body of Code

	 reg  done_flag;
	 reg  done_rst;

    //--------------------------------------------------------------------------
    // save input data (from upstream logic, compensated data) into a FIFO

    reg  [9 :0]  wr_cnt;
    reg  [23:0]  data_i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data_i <= 0;
        end
        else begin
            data_i <= {di_im, di_re};
        end
    end

    reg     wr_en;
    wire    full;

    localparam      WR_CNT_MAX = `N + 1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX) begin
                wr_en <= 0;
            end
            else if (!full) begin
                wr_en <= di_vld;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX) begin
                wr_cnt <= WR_CNT_MAX;
            end
            else if (di_vld) begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end

    //--------------------------------------------------------------------------
    // using a FSM control the whole process of this module

    localparam  [4:0]   RST      = 5'b0_0001;
    localparam  [4:0]   FFT_CFG  = 5'b0_0010;
    localparam  [4:0]   FFT_MUL  = 5'b0_0100;
    localparam  [4:0]   IFFT_CFG = 5'b0_1000;
    localparam  [4:0]   IFFT     = 5'b1_0000;

    reg     [4:0]   CS;
    reg     [4:0]   NS;

    //% FSM-1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            CS <= RST;
        end
        else begin
            CS <= NS;
        end
    end

    //% FSM-2
    always @* begin
        NS = 5'bx;
        case (CS)
            RST: begin
                if (rst) begin
                    NS = RST;
                end
                else begin
                    NS = FFT_CFG;
                end
            end
            FFT_CFG: begin
                if (rst) begin
                    NS = RST;
                end
                else if (s_config_tready) begin
                    NS = FFT_MUL;
                end
                else begin
                    NS = FFT_CFG;
                end
            end
            FFT_MUL: begin
                if (rst) begin
                    NS = RST;
                end
                else if (mul_cnt == `N) begin
                    NS = IFFT_CFG;
                end
                else begin
                    NS = FFT_MUL;
                end
            end
            IFFT_CFG: begin
                if (rst) begin
                    NS = RST;
                end
                else if (s_config_cnt > 2'd2 && s_config_tready) begin
                    NS = IFFT;
                end
                else begin
                    NS = IFFT_CFG;
                end
            end
            IFFT: begin
                if (rst) begin
                    NS = RST;
                end
                else begin
                    NS = IFFT;
                end
            end
            default: begin
                NS = RST;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // configure the FFT IP core

    reg           s_config_tvalid;      //% configure data valid flag
    wire          s_config_tready;      //% FFT core configuration ready flag
    reg   [15:0]  s_config_tdata;       //% configure data into FFT core

    reg   [1 :0]  s_config_cnt;         //% counter used to ensure IFFT_CFG

    // configuration for FFT
    localparam    FWD = 1'b1;
    localparam    SCH_FFT = 10'b10_10_10_10_11;  // avoid overflow

    // configuration for IFFT
    localparam    INV = 1'b0;
    localparam    SCH_IFFT = 10'b01_10_10_10_10;

    //% FSM-3: FFT IP core configuration
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_config_tvalid <= 0;
            s_config_tdata  <= 0;
            s_config_cnt    <= 0;
        end
        else begin
            s_config_tvalid <= 0;
            s_config_tdata  <= 0;
            case (NS)
                RST, FFT_MUL, IFFT: begin
                    // reset the s_config_cnt
                    s_config_cnt <= 0;
                end
                FFT_CFG: begin  // configure into FFT mode, no scaling
                    s_config_tvalid <= 1;
                    s_config_tdata  <= {5'b0, SCH_FFT, FWD};
                end
                IFFT_CFG: begin     // configure into IFFT mode, scale = 1/N
                    s_config_tvalid <= 1;
                    s_config_tdata  <= {5'b0, SCH_IFFT, INV};
                    // in orde to ensure the configuration is successful, 
                    // IFFT_CFG state must be more than 1 clock period
                    if (s_config_cnt == 2'd3) begin
                        s_config_cnt <= 2'd3;
                    end
                    else begin
                        s_config_cnt <= s_config_cnt + 1;
                    end
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // read data from input FIFO for FFT

    reg           rd_en;
    wire          empty;
    wire          data_o_vld;
    wire  [23:0]  data_o;

    reg  signed  [11:0]  data_re;
    reg  signed  [11:0]  data_im;
    reg                  data_vld;

    //% FSM-3: read received data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en    <= 0;
            data_re  <= 0;
            data_im  <= 0;
            data_vld <=0;
        end
        else begin
            rd_en    <= 0;
            data_re  <= 0;
            data_im  <= 0;
            data_vld <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // do not read
                end
                FFT_MUL: begin  // read data from the input FIFO
                    // rd_en
                    if (wr_cnt == WR_CNT_MAX && !empty) begin
                        rd_en <= 1;
                    end
                    else begin
                        rd_en <= 0;
                    end
                    // data_re/im
                    if (data_o_vld) begin
                        data_re <= data_o[11: 0];
                        data_im <= data_o[23:12];
                    end
                    else begin
                        data_re <= 0;
                        data_im <= 0;
                    end
                    // data_vld
                    data_vld <= data_o_vld;
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // prepare data for IFFT
   
    //--------------------------------------------------------------------------
    // FFT & IFFT operation

    // core input
    reg   [63:0]  s_data_tdata;
    reg           s_data_tvalid;
    reg           s_data_tlast;
    wire          s_data_tready;

    // core output
    wire  [63:0]  m_data_tdata;
    wire          m_data_tvalid;
    wire          m_data_tlast;
    wire          m_data_tready;

    // event signal, only for debug
    wire    event_frame_started;
    wire    event_tlast_unexpected;
    wire    event_tlast_missing;
    wire    event_data_in_channel_halt;
    wire    event_status_channel_halt;
    wire    event_data_out_channel_halt;
    
    //% downstream logic(FIFO) is always ready
    assign  m_data_tready = 1;

    reg  [9 :0]  s_data_samples_cnt;  //% counter used to generate the s_data_tlast

    //% FSM-3: s_data_tvalid/tdata
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_data_tvalid <= 0;
            s_data_tdata  <= 0;
        end
        else begin
            s_data_tvalid <= 0;
            s_data_tdata  <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG: begin
                    // do nothing
                end
                FFT_MUL: begin
                    s_data_tvalid <= data_vld;
                    s_data_tdata  <= {7'b0, {13{data_im[11]}}, data_im, 7'b0, {13{data_re[11]}}, data_re};
                end
                IFFT: begin
                    s_data_tdata <= {7'b0, fifo2_dout[49:25], 7'b0, fifo2_dout[24:0]};
                    s_data_tvalid <= fifo2_valid;
                end
            endcase
        end
    end

    //% FSM-3: s_data_samples_cnt/tlast
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_data_samples_cnt <= 0;
            s_data_tlast       <= 0;
        end
        else begin
            s_data_samples_cnt <= 0;
            s_data_tlast       <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG: begin
                    // do nothing
                end
                FFT_MUL: begin
                    // s_data_samples_cnt
                    if (s_data_samples_cnt == `N) begin
                        s_data_samples_cnt <= `N;
                    end
                    else if (data_vld) begin
                        s_data_samples_cnt <= s_data_samples_cnt + 1;
                    end
                    // s_data_tlast
                    if (s_data_samples_cnt == `N-1) begin
                        s_data_tlast <= 1;
                    end
                    else begin
                        s_data_tlast <= 0;
                    end
                end
                IFFT: begin
                    // s_data_samples_cnt
                    if (s_data_samples_cnt == `N) begin
                        s_data_samples_cnt <= `N;
                    end
                    else if (fifo2_valid) begin
                        s_data_samples_cnt <= s_data_samples_cnt + 1;
                    end
                    // s_data_tlast
                    if (s_data_samples_cnt == `N-1) begin
                        s_data_tlast <= 1;
                    end
                end
            endcase
        end
    end

    // FFT result
    reg                  fft_out_vld;
    reg  signed  [11:0]  fft_out_re;
    reg  signed  [11:0]  fft_out_im;

    //% FSM-3: get the FFT result
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            fft_out_vld <= 0;
            fft_out_re  <= 0;
            fft_out_im  <= 0;
        end
        else begin
            fft_out_vld <= 0;
            fft_out_re  <= 0;
            fft_out_im  <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // do nothing
                end
                FFT_MUL: begin
                    fft_out_vld <= m_data_tvalid;
                    fft_out_re  <= m_data_tdata[11: 0];
                    fft_out_im  <= m_data_tdata[43:32];
                end
            endcase
        end
    end

    reg                  fft_out_vld_r1;
    reg                  fft_out_vld_r2;
    reg                  fft_out_vld_r3;
    reg  signed  [11:0]  fft_out_re_r1;
    reg  signed  [11:0]  fft_out_re_r2;
    reg  signed  [11:0]  fft_out_re_r3;
    reg  signed  [11:0]  fft_out_im_r1;
    reg  signed  [11:0]  fft_out_im_r2;
    reg  signed  [11:0]  fft_out_im_r3;

    //% FSM-3: align the fft result & local ROM output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            fft_out_vld_r1 <= 0;
            fft_out_vld_r2 <= 0;
            fft_out_vld_r3 <= 0;
            fft_out_re_r1  <= 0;
            fft_out_re_r2  <= 0;
            fft_out_re_r3  <= 0;
            fft_out_im_r1  <= 0;
            fft_out_im_r2  <= 0;
            fft_out_im_r3  <= 0;
        end
        else begin
            fft_out_vld_r1 <= 0;
            fft_out_vld_r2 <= 0;
            fft_out_vld_r3 <= 0;
            fft_out_re_r1  <= 0;
            fft_out_re_r2  <= 0;
            fft_out_re_r3  <= 0;
            fft_out_im_r1  <= 0;
            fft_out_im_r2  <= 0;
            fft_out_im_r3  <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // do nothing
                end
                FFT_MUL: begin
                    // fft output valid flag
                    fft_out_vld_r1 <= fft_out_vld;
                    fft_out_vld_r2 <= fft_out_vld_r1;
                    fft_out_vld_r3 <= fft_out_vld_r2;
                    // fft output real part
                    fft_out_re_r1 <= fft_out_re;
                    fft_out_re_r2 <= fft_out_re_r1;
                    fft_out_re_r3 <= fft_out_re_r2;
                    // fft output image part
                    fft_out_im_r1 <= fft_out_im;
                    fft_out_im_r2 <= fft_out_im_r1;
                    fft_out_im_r3 <= fft_out_im_r2;
                end
            endcase
        end
    end

    // read local preamble data
    reg                   ena;
    reg           [8 :0]  addra;
    wire  signed  [11:0]  douta_re;
    wire  signed  [11:0]  douta_im;

    //% FSM-3: read local ROM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            ena   <= 0;
            addra <= 9'b1_1111_1111;
        end
        else begin
            ena   <= 0;
            addra <= 9'b1_1111_1111;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // do nothing
                end
                FFT_MUL: begin
                    ena <= fft_out_vld;
                    if (fft_out_vld) begin
                        addra <= addra + 1;
                    end
                    else begin
                        addra <= 9'b1_1111_1111;
                    end
                end
            endcase
        end
    end

    // multiplie the received data with local data

    reg           s_mul_a_tvalid;
    reg   [31:0]  s_mul_a_tdata;
    reg           s_mul_b_tvalid;
    reg   [31:0]  s_mul_b_tdata;

    //% FSM-3: calculate the correlation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            s_mul_a_tvalid <= 0;
            s_mul_a_tdata  <= 0;
            s_mul_b_tvalid <= 0;
            s_mul_b_tdata  <= 0;
        end
        else begin
            s_mul_a_tvalid <= 0;
            s_mul_a_tdata  <= 0;
            s_mul_b_tvalid <= 0;
            s_mul_b_tdata  <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // do nothing
                end
                FFT_MUL: begin
                    s_mul_a_tvalid <= fft_out_vld_r3;
                    s_mul_a_tdata <= {4'b0, fft_out_im_r3, 4'b0, fft_out_re_r3};
                    s_mul_b_tvalid <= fft_out_vld_r3;
                    s_mul_b_tdata <= {4'b0, -douta_im, 4'b0, douta_re};
                end
            endcase
        end
    end

    wire          m_mul_dout_tvalid;
    wire  [63:0]  m_mul_dout_tdata;

    reg                  mul_data_vld;
    reg  signed  [24:0]  mul_data_re;
    reg  signed  [24:0]  mul_data_im;
    reg          [9: 0]  mul_cnt;    //% counter used to decide the state 
                                     //% transform from FFT_MUL to IFFT_CFG

    //% FSM-3: get the result of correlation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            mul_data_vld <= 0;
            mul_data_re  <= 0;
            mul_data_im  <= 0;
            mul_cnt      <= 0;
        end
        else begin
            mul_data_vld <= 0;
            mul_data_re  <= 0;
            mul_data_im  <= 0;
            case (NS)
                RST, FFT_CFG, IFFT_CFG, IFFT: begin
                    // reset the mul_cnt
                    mul_cnt <= 0;
                end
                FFT_MUL: begin
                    mul_data_vld <= m_mul_dout_tvalid;
                    mul_data_re  <= m_mul_dout_tdata[24: 0];
                    mul_data_im  <= m_mul_dout_tdata[56:32];
                    if (mul_cnt == `N) begin
                        mul_cnt <= `N;
                    end
                    else if (mul_data_vld) begin
                        mul_cnt <= mul_cnt + 1;
                    end
                end
            endcase
        end
    end

    // save the multiplied result into a FIFO

    reg  [49:0]  fifo2_din;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            fifo2_din <= 0;
        end
        else begin
            fifo2_din <= {mul_data_im, mul_data_re};
        end
    end

    reg         fifo2_wr_en;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            fifo2_wr_en <= 0;
        end
        else begin
            if (!full) begin
                fifo2_wr_en <= mul_data_vld;
            end
            else begin
                fifo2_wr_en <= 0;
            end
        end
    end

    reg           fifo2_rd_en;

    wire          fifo2_valid;
    wire  [49:0]  fifo2_dout;

    //% FSM-3: read out the multiplied result when FFT core is ready to IFFT
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            fifo2_rd_en <= 0;
        end
        else begin
            fifo2_rd_en <= 0;
            case (NS)
                RST, FFT_CFG, FFT_MUL, IFFT_CFG: begin
                    // do nothing
                end
                IFFT: begin
                    if (s_data_tready && !fifo2_empty) begin
                        fifo2_rd_en <= 1;
                    end
                    else begin
                        fifo2_rd_en <= 0;
                    end
                end
            endcase
        end
    end

    reg                  ifft_out_vld;
    reg  signed  [24:0]  ifft_out_re;
    reg  signed  [24:0]  ifft_out_im;

    //% FSM-3: get the ifft result
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            ifft_out_vld <= 0;
            ifft_out_re  <= 0;
            ifft_out_im  <= 0;
        end
        else begin
            ifft_out_vld <= 0;
            ifft_out_re  <= 0;
            ifft_out_im  <= 0;
            case (NS)
                RST, FFT_CFG, FFT_MUL, IFFT_CFG: begin
                    // do nothing
                end
                IFFT: begin
                    ifft_out_vld <= m_data_tvalid;
                    ifft_out_re  <= m_data_tdata[24: 0];
                    ifft_out_im  <= m_data_tdata[56:32];
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // instantiate the IP core

    //% FIFO core
    SSYNC_FIFO U_SSYNC_FIFO (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(data_i),      // input wire [23 : 0] din
        .wr_en(wr_en),  // input wire wr_en
        .rd_en(rd_en),  // input wire rd_en
        .dout(data_o),    // output wire [23 : 0] dout
        .full(full),    // output wire full
        .empty(empty),  // output wire empty
        .valid(data_o_vld)  // output wire valid
    );

    //% FFT IP core
    SSYNC_FFT U_SSYNC_FFT (
        .aclk(clk),                                                // input wire aclk
        
        .s_axis_config_tdata(s_config_tdata),                  // input wire [15 : 0] s_axis_config_tdata
        .s_axis_config_tvalid(s_config_tvalid),                // input wire s_axis_config_tvalid
        .s_axis_config_tready(s_config_tready),                // output wire s_axis_config_tready
        
        .s_axis_data_tdata(s_data_tdata),                      // input wire [63 : 0] s_axis_data_tdata
        .s_axis_data_tvalid(s_data_tvalid),                    // input wire s_axis_data_tvalid
        .s_axis_data_tready(s_data_tready),                    // output wire s_axis_data_tready
        .s_axis_data_tlast(s_data_tlast),                      // input wire s_axis_data_tlast
        
        .m_axis_data_tdata(m_data_tdata),                      // output wire [63 : 0] m_axis_data_tdata
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

    //% local preamble ROM, real part
    SSYNC_ROM_RE U_SSYNC_ROM_RE (
        .clka(clk),    // input wire clka
        .ena(ena),      // input wire ena
        .addra(addra),  // input wire [8 : 0] addra
        .douta(douta_re)  // output wire [11 : 0] douta
    );

    //% local preamble ROM, image part
    SSYNC_ROM_IM U_SSYNC_ROM_IM (
        .clka(clk),    // input wire clka
        .ena(ena),      // input wire ena
        .addra(addra),  // input wire [8 : 0] addra
        .douta(douta_im)  // output wire [11 : 0] douta
    );

    SSYNC_FIFO2 U_SSYNC_FIFO2 (
        .clk(clk),      // input wire clk
        .srst(rst),    // input wire srst
        .din(fifo2_din),      // input wire [49 : 0] din
        .wr_en(fifo2_wr_en),  // input wire wr_en
        .rd_en(fifo2_rd_en),  // input wire rd_en
        .dout(fifo2_dout),    // output wire [49 : 0] dout
        .full(fifo2_full),    // output wire full
        .empty(fifo2_empty),  // output wire empty
        .valid(fifo2_valid)  // output wire valid
    );

    //% complex multiplier
    SSYNC_MUL U_SSYNC_MUL (
        .aclk(clk),                              // input wire aclk
        .s_axis_a_tvalid(s_mul_a_tvalid),        // input wire s_axis_a_tvalid
        .s_axis_a_tdata(s_mul_a_tdata),          // input wire [31 : 0] s_axis_a_tdata
        .s_axis_b_tvalid(s_mul_b_tvalid),        // input wire s_axis_b_tvalid
        .s_axis_b_tdata(s_mul_b_tdata),          // input wire [31 : 0] s_axis_b_tdata
        .m_axis_dout_tvalid(m_mul_dout_tvalid),  // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(m_mul_dout_tdata)    // output wire [63 : 0] m_axis_dout_tdata
    );

    //--------------------------------------------------------------------------
    // get the output

    reg     [24:0]  abs_re;
    reg     [24:0]  abs_im;
    reg             abs_vld;
    reg     [25:0]  energy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            abs_re <= 0;
            abs_im <= 0;
        end
        else begin
            if (ifft_out_re[24] == 1) begin
                abs_re <= 25'd33554431 - ifft_out_re + 1;
            end
            else begin
                abs_re <= ifft_out_re;
            end
            if (ifft_out_im[24] == 1) begin
                abs_im <= 25'd33554431 - ifft_out_im + 1;
            end
            else begin
                abs_im <= ifft_out_im;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            abs_vld <= 0;
        end
        else begin
            abs_vld <= ifft_out_vld;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            energy <= 0;
        end
        else begin
            if (abs_vld) begin
                energy <= abs_re + abs_im;
            end
            else begin
                energy <= 0;
            end
        end
    end

    reg     [9:0]   energy_indx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            energy_indx <= 0;
        end
        else begin
            if (abs_vld) begin
                energy_indx <= energy_indx + 1;
            end
            else begin
                energy_indx <= 0;
            end
        end
    end

    reg     [25:0]  max;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            max <= 0;
            max_indx <= 0;
        end
        else begin
            if (energy > max) begin
                max <= energy;
                // max_indx <= energy_indx;
                max_indx <= energy_indx - 5;    // choose the 5th sample before the max energy
                                                // in case of ISI
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            max_indx_vld <= 0;
        end
        else begin
            if (energy_indx == `N) begin
                max_indx_vld <= 1;
            end
            else begin
                max_indx_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_re  <= 0;
            do_im  <= 0;
            do_vld <= 0;
        end
        else begin
            do_re  <= di_re;
            do_im  <= di_im;
            do_vld <= di_vld;
        end
    end
	 
	 integer  cnt_flag = 0;								//Modified by baiyf
	 always @(posedge clk or posedge rst) begin
		if(rst) begin
			cnt_flag <=0;
		end
		else begin
			if(do_vld) begin
				cnt_flag <= 1;
			end
		end
	 end
	 
	 always @(posedge clk or posedge rst) begin
		if(rst) begin
			done_flag <= 0;
		end
		else begin
			if(cnt_flag == 9535) begin
				done_flag <= 1;
			end
		end
	 end
	 
	 always @(posedge clk ) begin
		if(done_flag ) begin
			done_rst <= 1;
		end
		else begin
			done_rst <= 0;
		end
	 end
	 
endmodule