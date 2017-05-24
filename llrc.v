//% @file llrc.v
//% @brief Implementation file of LLR Calculation(LLRC) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-01-18

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% LLR Calculation (LLRC) calculate the llr
//% 
//% llr = 4*kf*Mi
//% 
//% 1. save Kf in RAM first
//% 2. read out when needed.
//% 3. calculate kf*mi
//% 4. calculate llr_tmp
//% 5. calculaate llr
//% 6. get do
module LLRC (
    input                        clk,
    input                        rst,
    input        signed  [11:0]  di_kf,
    input                        di_kf_vld,
    input        signed  [14:0]  di_mi,
    input                        di_mi_vld,
    output  reg  signed  [7 :0]  do,
    output  reg                  do_vld
    );

//=============================================================================
// Main Body of Code

    /**
     * 1. save Kf into RAM (480 samples)
     * 
     */
    reg          wea;
    reg  [8 :0]  addra;
    reg  [11:0]  dina;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wea <= 0;
            addra <= 9'd511;
            dina <= 0;
        end
        else begin
            wea <= di_kf_vld;
            dina <= di_kf;
            if (di_kf_vld) begin
                addra <= addra + 1;
            end
        end
    end

    /**
     * 2. when mi is valid, read out Kf from RAM
     */
    reg  [8 :0]  addrb;
    wire [11:0]  doutb;
    reg          doutb_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addrb <= 9'd511;
        end
        else begin
            if (di_mi_vld) begin
                if (addrb == 479) begin
                    addrb <= 9'd0;
                end
                else begin
                    addrb <= addrb + 1;
                end
            end
            else begin
                addrb <= 9'd511;
            end
        end
    end

    reg  doutb_vld_tmp1;
    reg  doutb_vld_tmp2;
    // doutb_vld is 3 clock later to di_mi_vld
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            doutb_vld_tmp1 <= 0;
            doutb_vld_tmp2 <= 0;
            doutb_vld <= 0;
        end
        else begin
            doutb_vld_tmp1 <= di_mi_vld;
            doutb_vld_tmp2 <= doutb_vld_tmp1;
            doutb_vld <= doutb_vld_tmp2;
        end
    end

    /**
     * 3. calculate kf*mi
     */

    // algin mi with kf
    // mi_tmp3  &&  doutb
    reg  signed  [14:0]  mi_tmp1;
    reg  signed  [14:0]  mi_tmp2;
    reg  signed  [14:0]  mi_tmp3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            mi_tmp1 <= 0;
            mi_tmp2 <= 0;
            mi_tmp3 <= 0;
        end
        else begin
            mi_tmp1 <= di_mi;
            mi_tmp2 <= mi_tmp1;
            mi_tmp3 <= mi_tmp2;
        end
    end

    reg  signed  [14:0]  A;
    reg  signed  [11:0]  B;
    wire signed  [26:0]  P;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            A <= 0;
            B <= 0;
        end
        else begin
            A <= mi_tmp3;
            B <= doutb;
        end
    end

    /**
     * 4. calculate llr_tmp
     */
    reg  P_vld;
    reg  P_vld_tmp1;
    reg  P_vld_tmp2;
    reg  P_vld_tmp3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            P_vld_tmp1 <= 0;
            P_vld_tmp2 <= 0;
            P_vld_tmp3 <= 0;
            P_vld <= 0;
        end
        else begin
            P_vld_tmp1 <= doutb_vld;
            P_vld_tmp2 <= P_vld_tmp1;
            P_vld_tmp3 <= P_vld_tmp2;
            P_vld <= P_vld_tmp3;
        end
    end

    /**
     * 5. calculate llr
     */
    
    // save llr_tmp into RAM
    wire         full;
    reg          wr_en;
    reg  [26:0]  din;

    localparam   WR_CNT_MAX = 8640;
    reg  [13:0]  wr_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
            din <= 0;
        end
        else begin
            if (P_vld && !full) begin
                if (wr_cnt == WR_CNT_MAX) begin
                    wr_en <= 0;
                    din <= 0;
                end
                else begin
                    wr_en <= 1;
                    din <= P;
                end
            end
            else begin
                wr_en <= 0;
                din <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 14'd0;
        end
        else begin
            if (P_vld && !full) begin
                if (wr_cnt < WR_CNT_MAX) begin
                    wr_cnt <= wr_cnt + 1;
                end
            end
            else begin
                wr_cnt <= 14'd0;
            end
        end
    end

    wire         empty;
    wire [26:0]  dout;
    reg          rd_en;
    wire         valid;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX - 2) begin  // read latency = 2
                rd_en <= 1;
            end
            else if (empty) begin
                rd_en <= 0;
            end
            else begin
                rd_en <= rd_en;
            end
        end
    end

    // valid & dout ; P_valid_vld & P_delay1

    reg  signed  [26:0]  P_delay1;
    reg                  P_delay1_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            P_delay1 <= 0;
            P_delay1_vld <= 0;
        end
        else begin
            P_delay1 <= P;
            P_delay1_vld <= P_vld;
        end
    end

    /**
     * 6. get do
     */

    // clock1: get abs & sign & sum
    // clock2: get max, delay sign & sum to align to max

    // get sign
    reg     sign;   // 0 = same sign; 1 = different sign
    reg     sign_delay1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sign <= 0;
            sign_delay1 <= 0;
        end
        else begin
            if (P_delay1[26] == dout[26]) begin
                sign <= 0;
            end
            else begin
                sign <= 1;
            end
            sign_delay1 <= sign;
        end
    end

    // get abs & max
    reg  [26:0]  dout_delay1;
    reg  [26:0]  P_delay2;
    reg  [26:0]  abs1;
    reg  [26:0]  abs2;
    reg  [26:0]  max;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout_delay1 <= 0;
            P_delay2 <= 0;
            abs1 <= 0;
            abs2 <= 0;
            max <= 0;
        end
        else begin
            dout_delay1 <= dout;
            P_delay2 <= P_delay1;
            // abs1
            if (dout[26] == 1) begin
                abs1 <= ~dout + 1;
            end
            else begin
                abs1 <= dout;
            end
            // abs2
            if (P_delay1[26] == 1) begin
                abs2 <= ~P_delay1 + 1;
            end
            else begin
                abs2 <= P_delay1;
            end
            // max
            if (abs1 > abs2) begin
                max <= dout_delay1;
            end
            else begin
                max <= P_delay2;
            end
        end
    end

    reg  signed  [27:0]  sum;
    reg  signed  [27:0]  sum_delay;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            sum <= 0;
            sum_delay <= 0;
        end
        else begin
            sum <= P_delay1 + dout;
            sum_delay <= sum;
        end
    end

    reg  signed  [27:0]  llr;
    reg                  llr_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            llr <= 0;
        end
        else begin
            if (sign_delay1) begin
                llr <= {max[26], max};
            end
            else begin
                llr <= sum_delay;
            end
        end
    end

    reg  llr_vld_tmp1;
    reg  llr_vld_tmp2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            llr_vld_tmp1 <= 0;
            llr_vld_tmp2 <= 0;
            llr_vld <= 0;
        end
        else begin
            llr_vld_tmp1 <= valid;
            llr_vld_tmp2 <= llr_vld_tmp1;
            llr_vld <= llr_vld_tmp2;
        end
    end

    // llr = integer(27:11) + fraction(10:0)
    // 
    // becase llr = 4*kf*mi, so llr final format is 18Q9
    // 
    // llr = integer(27:09) + fraction(08:0)
    reg  signed  [18:0]  int;
    reg  signed  [08:0]  frac;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            int  <= 0;
            frac <= 0;
        end
        else begin
            //% for version1.0
            // int  <= ~llr[27:09] + 1;
            // frac <= ~llr[08: 0] + 1;
            //% for version1.1
            int  <= llr[27:09];
            frac <= llr[08: 0];
        end
    end

    /**
     * LDPC decoder interface format is 3Q4 in 2'c complement
     * 
     * max = 0111.1111 = 7.9375
     * min = 1_0000_0000 - 0111.1111 = 1000.0001 = -7.9375
     */
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            if (int > 8) begin
                do <= {8'b0111_1111};   // max = 7.9375
            end
            else if (int < -4) begin
                do <= {8'b1000_0001};   // min = -7.9375
            end
            else begin
                do <= {int[3:0], frac[8:5]};
            end
        end
    end

    reg  do_vld_tmp1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld_tmp1 <= 0;
            do_vld      <= 0;
        end
        else begin
            do_vld_tmp1 <= llr_vld;
            do_vld      <= do_vld_tmp1;
        end
    end

    //-------------------------------------------------------------------------
    // instantiate the submodule

    LLRC_KF_RAM U_LLRC_KF_RAM (
        .clka(clk),    // input wire clka
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [8 : 0] addra
        .dina(dina),    // input wire [11 : 0] dina
        .clkb(clk),    // input wire clkb
        .rstb(rst),    // input wire rstb
        .addrb(addrb),  // input wire [8 : 0] addrb
        .doutb(doutb)  // output wire [11 : 0] doutb
    );

    LLCR_MULT U_LLCR_MULT (
        .clk(clk),  // input wire CLK
        .a(A),      // input wire [14 : 0] A
        .b(B),      // input wire [11 : 0] B
        .p(P)      // output wire [26 : 0] P
    );

    LLRC_FIFO U_LLRC_FIFO (
        .clk(clk),      // input wire clk
        .rst(rst),      // input wire rst
        .din(din),      // input wire [26 : 0] din
        .wr_en(wr_en),  // input wire wr_en
        .rd_en(rd_en),  // input wire rd_en
        .dout(dout),    // output wire [26 : 0] dout
        .full(full),    // output wire full
        .empty(empty),  // output wire empty
        .valid(valid)  // output wire valid
    );

endmodule