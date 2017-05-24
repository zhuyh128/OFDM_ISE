`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 09/07/2016 02:19:14 PM
// Design Name: 
// Module Name: ACS
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: add, compare & select
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
//

module ACS(
    input       clk,                        //% working clock
    input       rst,                        //% reset, active high
    input       [1:0] di0,                  //% input 8 branch distance
    input       [1:0] di1,                  //% 
    input       [1:0] di2,                  //% 
    input       [1:0] di3,                  //% 
    input       [1:0] di4,                  //% 
    input       [1:0] di5,                  //% 
    input       [1:0] di6,                  //% 
    input       [1:0] di7,                  //% 
    input       di_vld,                     //% 

    output reg  [63:0] do_sur,              //% output survive path
    output reg  do_sur_vld,                 //% output survive path valid
    output reg  [5:0] do_smallest_state,    //% output the state which has the smallest diatancce
    output reg  do_smallest_vld             //% output state valid
    );
    
    // inputs of SDS
    reg [11:0] dis_for_compare [0:63];

    // inputs of SUB_ACS
    reg [11:0] pre_accu_dis0;      // distance response to 64 state
    reg [11:0] pre_accu_dis1;
    reg [11:0] pre_accu_dis2;
    reg [11:0] pre_accu_dis3;
    reg [11:0] pre_accu_dis4;
    reg [11:0] pre_accu_dis5;
    reg [11:0] pre_accu_dis6;
    reg [11:0] pre_accu_dis7;
    reg [11:0] pre_accu_dis8;
    reg [11:0] pre_accu_dis9;
    reg [11:0] pre_accu_dis10;
    reg [11:0] pre_accu_dis11;
    reg [11:0] pre_accu_dis12;
    reg [11:0] pre_accu_dis13;
    reg [11:0] pre_accu_dis14;
    reg [11:0] pre_accu_dis15;
    reg [11:0] pre_accu_dis16;
    reg [11:0] pre_accu_dis17;
    reg [11:0] pre_accu_dis18;
    reg [11:0] pre_accu_dis19;
    reg [11:0] pre_accu_dis20;
    reg [11:0] pre_accu_dis21;
    reg [11:0] pre_accu_dis22;
    reg [11:0] pre_accu_dis23;
    reg [11:0] pre_accu_dis24;
    reg [11:0] pre_accu_dis25;
    reg [11:0] pre_accu_dis26;
    reg [11:0] pre_accu_dis27;
    reg [11:0] pre_accu_dis28;
    reg [11:0] pre_accu_dis29;
    reg [11:0] pre_accu_dis30;
    reg [11:0] pre_accu_dis31;
    reg [11:0] pre_accu_dis32;
    reg [11:0] pre_accu_dis33;
    reg [11:0] pre_accu_dis34;
    reg [11:0] pre_accu_dis35;
    reg [11:0] pre_accu_dis36;
    reg [11:0] pre_accu_dis37;
    reg [11:0] pre_accu_dis38;
    reg [11:0] pre_accu_dis39;
    reg [11:0] pre_accu_dis40;
    reg [11:0] pre_accu_dis41;
    reg [11:0] pre_accu_dis42;
    reg [11:0] pre_accu_dis43;
    reg [11:0] pre_accu_dis44;
    reg [11:0] pre_accu_dis45;
    reg [11:0] pre_accu_dis46;
    reg [11:0] pre_accu_dis47;
    reg [11:0] pre_accu_dis48;
    reg [11:0] pre_accu_dis49;
    reg [11:0] pre_accu_dis50;
    reg [11:0] pre_accu_dis51;
    reg [11:0] pre_accu_dis52;
    reg [11:0] pre_accu_dis53;
    reg [11:0] pre_accu_dis54;
    reg [11:0] pre_accu_dis55;
    reg [11:0] pre_accu_dis56;
    reg [11:0] pre_accu_dis57;
    reg [11:0] pre_accu_dis58;
    reg [11:0] pre_accu_dis59;
    reg [11:0] pre_accu_dis60;
    reg [11:0] pre_accu_dis61;
    reg [11:0] pre_accu_dis62;
    reg [11:0] pre_accu_dis63;

    // outputs of SUB_ACS
    wire [11:0] cur_accu_dis0;
    wire [11:0] cur_accu_dis1;
    wire [11:0] cur_accu_dis2;
    wire [11:0] cur_accu_dis3;
    wire [11:0] cur_accu_dis4;
    wire [11:0] cur_accu_dis5;
    wire [11:0] cur_accu_dis6;
    wire [11:0] cur_accu_dis7;
    wire [11:0] cur_accu_dis8;
    wire [11:0] cur_accu_dis9;
    wire [11:0] cur_accu_dis10;
    wire [11:0] cur_accu_dis11;
    wire [11:0] cur_accu_dis12;
    wire [11:0] cur_accu_dis13;
    wire [11:0] cur_accu_dis14;
    wire [11:0] cur_accu_dis15;
    wire [11:0] cur_accu_dis16;
    wire [11:0] cur_accu_dis17;
    wire [11:0] cur_accu_dis18;
    wire [11:0] cur_accu_dis19;
    wire [11:0] cur_accu_dis20;
    wire [11:0] cur_accu_dis21;
    wire [11:0] cur_accu_dis22;
    wire [11:0] cur_accu_dis23;
    wire [11:0] cur_accu_dis24;
    wire [11:0] cur_accu_dis25;
    wire [11:0] cur_accu_dis26;
    wire [11:0] cur_accu_dis27;
    wire [11:0] cur_accu_dis28;
    wire [11:0] cur_accu_dis29;
    wire [11:0] cur_accu_dis30;
    wire [11:0] cur_accu_dis31;
    wire [11:0] cur_accu_dis32;
    wire [11:0] cur_accu_dis33;
    wire [11:0] cur_accu_dis34;
    wire [11:0] cur_accu_dis35;
    wire [11:0] cur_accu_dis36;
    wire [11:0] cur_accu_dis37;
    wire [11:0] cur_accu_dis38;
    wire [11:0] cur_accu_dis39;
    wire [11:0] cur_accu_dis40;
    wire [11:0] cur_accu_dis41;
    wire [11:0] cur_accu_dis42;
    wire [11:0] cur_accu_dis43;
    wire [11:0] cur_accu_dis44;
    wire [11:0] cur_accu_dis45;
    wire [11:0] cur_accu_dis46;
    wire [11:0] cur_accu_dis47;
    wire [11:0] cur_accu_dis48;
    wire [11:0] cur_accu_dis49;
    wire [11:0] cur_accu_dis50;
    wire [11:0] cur_accu_dis51;
    wire [11:0] cur_accu_dis52;
    wire [11:0] cur_accu_dis53;
    wire [11:0] cur_accu_dis54;
    wire [11:0] cur_accu_dis55;
    wire [11:0] cur_accu_dis56;
    wire [11:0] cur_accu_dis57;
    wire [11:0] cur_accu_dis58;
    wire [11:0] cur_accu_dis59;
    wire [11:0] cur_accu_dis60;
    wire [11:0] cur_accu_dis61;
    wire [11:0] cur_accu_dis62;
    wire [11:0] cur_accu_dis63;

    wire do_sur_tmp0;
    wire do_sur_tmp1;
    wire do_sur_tmp2;
    wire do_sur_tmp3;
    wire do_sur_tmp4;
    wire do_sur_tmp5;
    wire do_sur_tmp6;
    wire do_sur_tmp7;
    wire do_sur_tmp8;
    wire do_sur_tmp9;
    wire do_sur_tmp10;
    wire do_sur_tmp11;
    wire do_sur_tmp12;
    wire do_sur_tmp13;
    wire do_sur_tmp14;
    wire do_sur_tmp15;
    wire do_sur_tmp16;
    wire do_sur_tmp17;
    wire do_sur_tmp18;
    wire do_sur_tmp19;
    wire do_sur_tmp20;
    wire do_sur_tmp21;
    wire do_sur_tmp22;
    wire do_sur_tmp23;
    wire do_sur_tmp24;
    wire do_sur_tmp25;
    wire do_sur_tmp26;
    wire do_sur_tmp27;
    wire do_sur_tmp28;
    wire do_sur_tmp29;
    wire do_sur_tmp30;
    wire do_sur_tmp31;
    wire do_sur_tmp32;
    wire do_sur_tmp33;
    wire do_sur_tmp34;
    wire do_sur_tmp35;
    wire do_sur_tmp36;
    wire do_sur_tmp37;
    wire do_sur_tmp38;
    wire do_sur_tmp39;
    wire do_sur_tmp40;
    wire do_sur_tmp41;
    wire do_sur_tmp42;
    wire do_sur_tmp43;
    wire do_sur_tmp44;
    wire do_sur_tmp45;
    wire do_sur_tmp46;
    wire do_sur_tmp47;
    wire do_sur_tmp48;
    wire do_sur_tmp49;
    wire do_sur_tmp50;
    wire do_sur_tmp51;
    wire do_sur_tmp52;
    wire do_sur_tmp53;
    wire do_sur_tmp54;
    wire do_sur_tmp55;
    wire do_sur_tmp56;
    wire do_sur_tmp57;
    wire do_sur_tmp58;
    wire do_sur_tmp59;
    wire do_sur_tmp60;
    wire do_sur_tmp61;
    wire do_sur_tmp62;
    wire do_sur_tmp63;

    reg [1:0] intmp00;
    reg [1:0] intmp01;
    reg [1:0] intmp02;
    reg [1:0] intmp03;
    reg [1:0] intmp04;
    reg [1:0] intmp05;
    reg [1:0] intmp06;
    reg [1:0] intmp07;

    reg [1:0] intmp10;
    reg [1:0] intmp11;
    reg [1:0] intmp12;
    reg [1:0] intmp13;
    reg [1:0] intmp14;
    reg [1:0] intmp15;
    reg [1:0] intmp16;
    reg [1:0] intmp17;

    reg [1:0] intmp20;
    reg [1:0] intmp21;
    reg [1:0] intmp22;
    reg [1:0] intmp23;
    reg [1:0] intmp24;
    reg [1:0] intmp25;
    reg [1:0] intmp26;
    reg [1:0] intmp27;

    reg [1:0] intmp30;
    reg [1:0] intmp31;
    reg [1:0] intmp32;
    reg [1:0] intmp33;
    reg [1:0] intmp34;
    reg [1:0] intmp35;
    reg [1:0] intmp36;
    reg [1:0] intmp37;

    reg [1:0] intmp40;
    reg [1:0] intmp41;
    reg [1:0] intmp42;
    reg [1:0] intmp43;
    reg [1:0] intmp44;
    reg [1:0] intmp45;
    reg [1:0] intmp46;
    reg [1:0] intmp47;

    reg [1:0] intmp50;
    reg [1:0] intmp51;
    reg [1:0] intmp52;
    reg [1:0] intmp53;
    reg [1:0] intmp54;
    reg [1:0] intmp55;
    reg [1:0] intmp56;
    reg [1:0] intmp57;

    reg [1:0] intmp60;
    reg [1:0] intmp61;
    reg [1:0] intmp62;
    reg [1:0] intmp63;
    reg [1:0] intmp64;
    reg [1:0] intmp65;
    reg [1:0] intmp66;
    reg [1:0] intmp67;

    reg [1:0] intmp70;
    reg [1:0] intmp71;
    reg [1:0] intmp72;
    reg [1:0] intmp73;
    reg [1:0] intmp74;
    reg [1:0] intmp75;
    reg [1:0] intmp76;
    reg [1:0] intmp77;

    reg in_vld0;
    reg in_vld1;
    reg in_vld2;
    reg in_vld3;
    reg in_vld4;
    reg in_vld5;
    reg in_vld6;
    reg in_vld7;

    wire in_vld;

    reg [6:0] acs_cnt;

    // get SDS valid signal, small_en
    reg small_en;
    reg [5:0] small_cnt;

    // input signal of SDS
    reg [11:0] small_dis_tmp0;
    reg [11:0] small_dis_tmp1;
    reg [5:0] small_state_tmp0;
    reg [5:0] small_state_tmp1;

    // output signal of SDS
    wire [11:0] smaller_dis;
    wire [5:0] smaller_state;
    
    // get SDS output valid signal
    reg smallest_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp00 <= 0;
            intmp01 <= 0;
            intmp02 <= 0;
            intmp03 <= 0;
            intmp04 <= 0;
            intmp05 <= 0;
            intmp06 <= 0;
            intmp07 <= 0;
            in_vld0 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp00 <= di0;
                intmp01 <= di1;
                intmp02 <= di2;
                intmp03 <= di3;
                intmp04 <= di4;
                intmp05 <= di5;
                intmp06 <= di6;
                intmp07 <= di7;
                in_vld0 <= di_vld;
            end
            else begin
                intmp00 <= 0;
                intmp01 <= 0;
                intmp02 <= 0;
                intmp03 <= 0;
                intmp04 <= 0;
                intmp05 <= 0;
                intmp06 <= 0;
                intmp07 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld0 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp10 <= 0;
            intmp11 <= 0;
            intmp12 <= 0;
            intmp13 <= 0;
            intmp14 <= 0;
            intmp15 <= 0;
            intmp16 <= 0;
            intmp17 <= 0;
            in_vld1 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp10 <= di0;
                intmp11 <= di1;
                intmp12 <= di2;
                intmp13 <= di3;
                intmp14 <= di4;
                intmp15 <= di5;
                intmp16 <= di6;
                intmp17 <= di7;
                in_vld1 <= di_vld;
            end
            else begin
                intmp10 <= 0;
                intmp11 <= 0;
                intmp12 <= 0;
                intmp13 <= 0;
                intmp14 <= 0;
                intmp15 <= 0;
                intmp16 <= 0;
                intmp17 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld1 <= 0;
                end
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp20 <= 0;
            intmp21 <= 0;
            intmp22 <= 0;
            intmp23 <= 0;
            intmp24 <= 0;
            intmp25 <= 0;
            intmp26 <= 0;
            intmp27 <= 0;
            in_vld2 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp20 <= di0;
                intmp21 <= di1;
                intmp22 <= di2;
                intmp23 <= di3;
                intmp24 <= di4;
                intmp25 <= di5;
                intmp26 <= di6;
                intmp27 <= di7;
                in_vld2 <= di_vld;
            end
            else begin
                intmp20 <= 0;
                intmp21 <= 0;
                intmp22 <= 0;
                intmp23 <= 0;
                intmp24 <= 0;
                intmp25 <= 0;
                intmp26 <= 0;
                intmp27 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld2 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp30 <= 0;
            intmp31 <= 0;
            intmp32 <= 0;
            intmp33 <= 0;
            intmp34 <= 0;
            intmp35 <= 0;
            intmp36 <= 0;
            intmp37 <= 0;
            in_vld3 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp30 <= di0;
                intmp31 <= di1;
                intmp32 <= di2;
                intmp33 <= di3;
                intmp34 <= di4;
                intmp35 <= di5;
                intmp36 <= di6;
                intmp37 <= di7;
                in_vld3 <= di_vld;
            end
            else begin
                intmp30 <= 0;
                intmp31 <= 0;
                intmp32 <= 0;
                intmp33 <= 0;
                intmp34 <= 0;
                intmp35 <= 0;
                intmp36 <= 0;
                intmp37 <= 0;
                if (acs_cnt == 95) begin
                    in_vld3 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp40 <= 0;
            intmp41 <= 0;
            intmp42 <= 0;
            intmp43 <= 0;
            intmp44 <= 0;
            intmp45 <= 0;
            intmp46 <= 0;
            intmp47 <= 0;
            in_vld4 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp40 <= di0;
                intmp41 <= di1;
                intmp42 <= di2;
                intmp43 <= di3;
                intmp44 <= di4;
                intmp45 <= di5;
                intmp46 <= di6;
                intmp47 <= di7;
                in_vld4 <= di_vld;
            end
            else begin
                intmp40 <= 0;
                intmp41 <= 0;
                intmp42 <= 0;
                intmp43 <= 0;
                intmp44 <= 0;
                intmp45 <= 0;
                intmp46 <= 0;
                intmp47 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld4 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp50 <= 0;
            intmp51 <= 0;
            intmp52 <= 0;
            intmp53 <= 0;
            intmp54 <= 0;
            intmp55 <= 0;
            intmp56 <= 0;
            intmp57 <= 0;
            in_vld5 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp50 <= di0;
                intmp51 <= di1;
                intmp52 <= di2;
                intmp53 <= di3;
                intmp54 <= di4;
                intmp55 <= di5;
                intmp56 <= di6;
                intmp57 <= di7;
                in_vld5 <= di_vld;
            end
            else begin
                intmp50 <= 0;
                intmp51 <= 0;
                intmp52 <= 0;
                intmp53 <= 0;
                intmp54 <= 0;
                intmp55 <= 0;
                intmp56 <= 0;
                intmp57 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld5 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp60 <= 0;
            intmp61 <= 0;
            intmp62 <= 0;
            intmp63 <= 0;
            intmp64 <= 0;
            intmp65 <= 0;
            intmp66 <= 0;
            intmp67 <= 0;
            in_vld6 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp60 <= di0;
                intmp61 <= di1;
                intmp62 <= di2;
                intmp63 <= di3;
                intmp64 <= di4;
                intmp65 <= di5;
                intmp66 <= di6;
                intmp67 <= di7;
                in_vld6 <= di_vld;
            end
            else begin
                intmp60 <= 0;
                intmp61 <= 0;
                intmp62 <= 0;
                intmp63 <= 0;
                intmp64 <= 0;
                intmp65 <= 0;
                intmp66 <= 0;
                intmp67 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld6 <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            intmp70 <= 0;
            intmp71 <= 0;
            intmp72 <= 0;
            intmp73 <= 0;
            intmp74 <= 0;
            intmp75 <= 0;
            intmp76 <= 0;
            intmp77 <= 0;
            in_vld7 <= 0;
        end
        else begin
            if (di_vld) begin
                intmp70 <= di0;
                intmp71 <= di1;
                intmp72 <= di2;
                intmp73 <= di3;
                intmp74 <= di4;
                intmp75 <= di5;
                intmp76 <= di6;
                intmp77 <= di7;
                in_vld7 <= di_vld;
            end
            else begin
                intmp70 <= 0;
                intmp71 <= 0;
                intmp72 <= 0;
                intmp73 <= 0;
                intmp74 <= 0;
                intmp75 <= 0;
                intmp76 <= 0;
                intmp77 <= 0;
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    in_vld7 <= 0;
                end
            end
        end
    end

    // get in_vld
    assign in_vld = (in_vld0 || in_vld1 || in_vld2 || in_vld3 || in_vld4 || in_vld5 || in_vld6 || in_vld7);


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            acs_cnt <= 0;
        end
        else begin
            if (in_vld) begin
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    acs_cnt <= 0;
                end
                else begin
                    acs_cnt <= acs_cnt + 1;
                end
            end
            else begin
                acs_cnt <= 0;
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            pre_accu_dis0 <= 0;
            pre_accu_dis1 <= 0;
            pre_accu_dis2 <= 0;
            pre_accu_dis3 <= 0;
            pre_accu_dis4 <= 0;
            pre_accu_dis5 <= 0;
            pre_accu_dis6 <= 0;
            pre_accu_dis7 <= 0;
            pre_accu_dis8 <= 0;
            pre_accu_dis9 <= 0;
            pre_accu_dis10 <= 0;
            pre_accu_dis11 <= 0;
            pre_accu_dis12 <= 0;
            pre_accu_dis13 <= 0;
            pre_accu_dis14 <= 0;
            pre_accu_dis15 <= 0;
            pre_accu_dis16 <= 0;
            pre_accu_dis17 <= 0;
            pre_accu_dis18 <= 0;
            pre_accu_dis19 <= 0;
            pre_accu_dis20 <= 0;
            pre_accu_dis21 <= 0;
            pre_accu_dis22 <= 0;
            pre_accu_dis23 <= 0;
            pre_accu_dis24 <= 0;
            pre_accu_dis25 <= 0;
            pre_accu_dis26 <= 0;
            pre_accu_dis27 <= 0;
            pre_accu_dis28 <= 0;
            pre_accu_dis29 <= 0;
            pre_accu_dis30 <= 0;
            pre_accu_dis31 <= 0;
            pre_accu_dis32 <= 0;
            pre_accu_dis33 <= 0;
            pre_accu_dis34 <= 0;
            pre_accu_dis35 <= 0;
            pre_accu_dis36 <= 0;
            pre_accu_dis37 <= 0;
            pre_accu_dis38 <= 0;
            pre_accu_dis39 <= 0;
            pre_accu_dis40 <= 0;
            pre_accu_dis41 <= 0;
            pre_accu_dis42 <= 0;
            pre_accu_dis43 <= 0;
            pre_accu_dis44 <= 0;
            pre_accu_dis45 <= 0;
            pre_accu_dis46 <= 0;
            pre_accu_dis47 <= 0;
            pre_accu_dis48 <= 0;
            pre_accu_dis49 <= 0;
            pre_accu_dis50 <= 0;
            pre_accu_dis51 <= 0;
            pre_accu_dis52 <= 0;
            pre_accu_dis53 <= 0;
            pre_accu_dis54 <= 0;
            pre_accu_dis55 <= 0;
            pre_accu_dis56 <= 0;
            pre_accu_dis57 <= 0;
            pre_accu_dis58 <= 0;
            pre_accu_dis59 <= 0;
            pre_accu_dis60 <= 0;
            pre_accu_dis61 <= 0;
            pre_accu_dis62 <= 0;
            pre_accu_dis63 <= 0;

            // inputs of SDS
            dis_for_compare[0] <= 0;
            dis_for_compare[1] <= 0;
            dis_for_compare[2] <= 0;
            dis_for_compare[3] <= 0;
            dis_for_compare[4] <= 0;
            dis_for_compare[5] <= 0;
            dis_for_compare[6] <= 0;
            dis_for_compare[7] <= 0;
            dis_for_compare[8] <= 0;
            dis_for_compare[9] <= 0;
            dis_for_compare[10] <= 0;
            dis_for_compare[11] <= 0;
            dis_for_compare[12] <= 0;
            dis_for_compare[13] <= 0;
            dis_for_compare[14] <= 0;
            dis_for_compare[15] <= 0;
            dis_for_compare[16] <= 0;
            dis_for_compare[17] <= 0;
            dis_for_compare[18] <= 0;
            dis_for_compare[19] <= 0;
            dis_for_compare[20] <= 0;
            dis_for_compare[21] <= 0;
            dis_for_compare[22] <= 0;
            dis_for_compare[23] <= 0;
            dis_for_compare[24] <= 0;
            dis_for_compare[25] <= 0;
            dis_for_compare[26] <= 0;
            dis_for_compare[27] <= 0;
            dis_for_compare[28] <= 0;
            dis_for_compare[29] <= 0;
            dis_for_compare[30] <= 0;
            dis_for_compare[31] <= 0;
            dis_for_compare[32] <= 0;
            dis_for_compare[33] <= 0;
            dis_for_compare[34] <= 0;
            dis_for_compare[35] <= 0;
            dis_for_compare[36] <= 0;
            dis_for_compare[37] <= 0;
            dis_for_compare[38] <= 0;
            dis_for_compare[39] <= 0;
            dis_for_compare[40] <= 0;
            dis_for_compare[41] <= 0;
            dis_for_compare[42] <= 0;
            dis_for_compare[43] <= 0;
            dis_for_compare[44] <= 0;
            dis_for_compare[45] <= 0;
            dis_for_compare[46] <= 0;
            dis_for_compare[47] <= 0;
            dis_for_compare[48] <= 0;
            dis_for_compare[49] <= 0;
            dis_for_compare[50] <= 0;
            dis_for_compare[51] <= 0;
            dis_for_compare[52] <= 0;
            dis_for_compare[53] <= 0;
            dis_for_compare[54] <= 0;
            dis_for_compare[55] <= 0;
            dis_for_compare[56] <= 0;
            dis_for_compare[57] <= 0;
            dis_for_compare[58] <= 0;
            dis_for_compare[59] <= 0;
            dis_for_compare[60] <= 0;
            dis_for_compare[61] <= 0;
            dis_for_compare[62] <= 0;
            dis_for_compare[63] <= 0;
        end
        else begin
            if (in_vld) begin
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    pre_accu_dis0 <= cur_accu_dis0 >> 1;
                    pre_accu_dis1 <= cur_accu_dis1 >> 1;
                    pre_accu_dis2 <= cur_accu_dis2 >> 1;
                    pre_accu_dis3 <= cur_accu_dis3 >> 1;
                    pre_accu_dis4 <= cur_accu_dis4 >> 1;
                    pre_accu_dis5 <= cur_accu_dis5 >> 1;
                    pre_accu_dis6 <= cur_accu_dis6 >> 1;
                    pre_accu_dis7 <= cur_accu_dis7 >> 1;
                    pre_accu_dis8 <= cur_accu_dis8 >> 1;
                    pre_accu_dis9 <= cur_accu_dis9 >> 1;
                    pre_accu_dis10 <= cur_accu_dis10 >> 1;
                    pre_accu_dis11 <= cur_accu_dis11 >> 1;
                    pre_accu_dis12 <= cur_accu_dis12 >> 1;
                    pre_accu_dis13 <= cur_accu_dis13 >> 1;
                    pre_accu_dis14 <= cur_accu_dis14 >> 1;
                    pre_accu_dis15 <= cur_accu_dis15 >> 1;
                    pre_accu_dis16 <= cur_accu_dis16 >> 1;
                    pre_accu_dis17 <= cur_accu_dis17 >> 1;
                    pre_accu_dis18 <= cur_accu_dis18 >> 1;
                    pre_accu_dis19 <= cur_accu_dis19 >> 1;
                    pre_accu_dis20 <= cur_accu_dis20 >> 1;
                    pre_accu_dis21 <= cur_accu_dis21 >> 1;
                    pre_accu_dis22 <= cur_accu_dis22 >> 1;
                    pre_accu_dis23 <= cur_accu_dis23 >> 1;
                    pre_accu_dis24 <= cur_accu_dis24 >> 1;
                    pre_accu_dis25 <= cur_accu_dis25 >> 1;
                    pre_accu_dis26 <= cur_accu_dis26 >> 1;
                    pre_accu_dis27 <= cur_accu_dis27 >> 1;
                    pre_accu_dis28 <= cur_accu_dis28 >> 1;
                    pre_accu_dis29 <= cur_accu_dis29 >> 1;
                    pre_accu_dis30 <= cur_accu_dis30 >> 1;
                    pre_accu_dis31 <= cur_accu_dis31 >> 1;
                    pre_accu_dis32 <= cur_accu_dis32 >> 1;
                    pre_accu_dis33 <= cur_accu_dis33 >> 1;
                    pre_accu_dis34 <= cur_accu_dis34 >> 1;
                    pre_accu_dis35 <= cur_accu_dis35 >> 1;
                    pre_accu_dis36 <= cur_accu_dis36 >> 1;
                    pre_accu_dis37 <= cur_accu_dis37 >> 1;
                    pre_accu_dis38 <= cur_accu_dis38 >> 1;
                    pre_accu_dis39 <= cur_accu_dis39 >> 1;
                    pre_accu_dis40 <= cur_accu_dis40 >> 1;
                    pre_accu_dis41 <= cur_accu_dis41 >> 1;
                    pre_accu_dis42 <= cur_accu_dis42 >> 1;
                    pre_accu_dis43 <= cur_accu_dis43 >> 1;
                    pre_accu_dis44 <= cur_accu_dis44 >> 1;
                    pre_accu_dis45 <= cur_accu_dis45 >> 1;
                    pre_accu_dis46 <= cur_accu_dis46 >> 1;
                    pre_accu_dis47 <= cur_accu_dis47 >> 1;
                    pre_accu_dis48 <= cur_accu_dis48 >> 1;
                    pre_accu_dis49 <= cur_accu_dis49 >> 1;
                    pre_accu_dis50 <= cur_accu_dis50 >> 1;
                    pre_accu_dis51 <= cur_accu_dis51 >> 1;
                    pre_accu_dis52 <= cur_accu_dis52 >> 1;
                    pre_accu_dis53 <= cur_accu_dis53 >> 1;
                    pre_accu_dis54 <= cur_accu_dis54 >> 1;
                    pre_accu_dis55 <= cur_accu_dis55 >> 1;
                    pre_accu_dis56 <= cur_accu_dis56 >> 1;
                    pre_accu_dis57 <= cur_accu_dis57 >> 1;
                    pre_accu_dis58 <= cur_accu_dis58 >> 1;
                    pre_accu_dis59 <= cur_accu_dis59 >> 1;
                    pre_accu_dis60 <= cur_accu_dis60 >> 1;
                    pre_accu_dis61 <= cur_accu_dis61 >> 1;
                    pre_accu_dis62 <= cur_accu_dis62 >> 1;
                    pre_accu_dis63 <= cur_accu_dis63 >> 1;

                    
                    // inputs of SDS
                    dis_for_compare[0] <= cur_accu_dis0;
                    dis_for_compare[1] <= cur_accu_dis1;
                    dis_for_compare[2] <= cur_accu_dis2;
                    dis_for_compare[3] <= cur_accu_dis3;
                    dis_for_compare[4] <= cur_accu_dis4;
                    dis_for_compare[5] <= cur_accu_dis5;
                    dis_for_compare[6] <= cur_accu_dis6;
                    dis_for_compare[7] <= cur_accu_dis7;
                    dis_for_compare[8] <= cur_accu_dis8;
                    dis_for_compare[9] <= cur_accu_dis9;
                    dis_for_compare[10] <= cur_accu_dis10;
                    dis_for_compare[11] <= cur_accu_dis11;
                    dis_for_compare[12] <= cur_accu_dis12;
                    dis_for_compare[13] <= cur_accu_dis13;
                    dis_for_compare[14] <= cur_accu_dis14;
                    dis_for_compare[15] <= cur_accu_dis15;
                    dis_for_compare[16] <= cur_accu_dis16;
                    dis_for_compare[17] <= cur_accu_dis17;
                    dis_for_compare[18] <= cur_accu_dis18;
                    dis_for_compare[19] <= cur_accu_dis19;
                    dis_for_compare[20] <= cur_accu_dis20;
                    dis_for_compare[21] <= cur_accu_dis21;
                    dis_for_compare[22] <= cur_accu_dis22;
                    dis_for_compare[23] <= cur_accu_dis23;
                    dis_for_compare[24] <= cur_accu_dis24;
                    dis_for_compare[25] <= cur_accu_dis25;
                    dis_for_compare[26] <= cur_accu_dis26;
                    dis_for_compare[27] <= cur_accu_dis27;
                    dis_for_compare[28] <= cur_accu_dis28;
                    dis_for_compare[29] <= cur_accu_dis29;
                    dis_for_compare[30] <= cur_accu_dis30;
                    dis_for_compare[31] <= cur_accu_dis31;
                    dis_for_compare[32] <= cur_accu_dis32;
                    dis_for_compare[33] <= cur_accu_dis33;
                    dis_for_compare[34] <= cur_accu_dis34;
                    dis_for_compare[35] <= cur_accu_dis35;
                    dis_for_compare[36] <= cur_accu_dis36;
                    dis_for_compare[37] <= cur_accu_dis37;
                    dis_for_compare[38] <= cur_accu_dis38;
                    dis_for_compare[39] <= cur_accu_dis39;
                    dis_for_compare[40] <= cur_accu_dis40;
                    dis_for_compare[41] <= cur_accu_dis41;
                    dis_for_compare[42] <= cur_accu_dis42;
                    dis_for_compare[43] <= cur_accu_dis43;
                    dis_for_compare[44] <= cur_accu_dis44;
                    dis_for_compare[45] <= cur_accu_dis45;
                    dis_for_compare[46] <= cur_accu_dis46;
                    dis_for_compare[47] <= cur_accu_dis47;
                    dis_for_compare[48] <= cur_accu_dis48;
                    dis_for_compare[49] <= cur_accu_dis49;
                    dis_for_compare[50] <= cur_accu_dis50;
                    dis_for_compare[51] <= cur_accu_dis51;
                    dis_for_compare[52] <= cur_accu_dis52;
                    dis_for_compare[53] <= cur_accu_dis53;
                    dis_for_compare[54] <= cur_accu_dis54;
                    dis_for_compare[55] <= cur_accu_dis55;
                    dis_for_compare[56] <= cur_accu_dis56;
                    dis_for_compare[57] <= cur_accu_dis57;
                    dis_for_compare[58] <= cur_accu_dis58;
                    dis_for_compare[59] <= cur_accu_dis59;
                    dis_for_compare[60] <= cur_accu_dis60;
                    dis_for_compare[61] <= cur_accu_dis61;
                    dis_for_compare[62] <= cur_accu_dis62;
                    dis_for_compare[63] <= cur_accu_dis63;
                end
                else begin
                    pre_accu_dis0 <= cur_accu_dis0;
                    pre_accu_dis1 <= cur_accu_dis1;
                    pre_accu_dis2 <= cur_accu_dis2;
                    pre_accu_dis3 <= cur_accu_dis3;
                    pre_accu_dis4 <= cur_accu_dis4;
                    pre_accu_dis5 <= cur_accu_dis5;
                    pre_accu_dis6 <= cur_accu_dis6;
                    pre_accu_dis7 <= cur_accu_dis7;
                    pre_accu_dis8 <= cur_accu_dis8;
                    pre_accu_dis9 <= cur_accu_dis9;
                    pre_accu_dis10 <= cur_accu_dis10;
                    pre_accu_dis11 <= cur_accu_dis11;
                    pre_accu_dis12 <= cur_accu_dis12;
                    pre_accu_dis13 <= cur_accu_dis13;
                    pre_accu_dis14 <= cur_accu_dis14;
                    pre_accu_dis15 <= cur_accu_dis15;
                    pre_accu_dis16 <= cur_accu_dis16;
                    pre_accu_dis17 <= cur_accu_dis17;
                    pre_accu_dis18 <= cur_accu_dis18;
                    pre_accu_dis19 <= cur_accu_dis19;
                    pre_accu_dis20 <= cur_accu_dis20;
                    pre_accu_dis21 <= cur_accu_dis21;
                    pre_accu_dis22 <= cur_accu_dis22;
                    pre_accu_dis23 <= cur_accu_dis23;
                    pre_accu_dis24 <= cur_accu_dis24;
                    pre_accu_dis25 <= cur_accu_dis25;
                    pre_accu_dis26 <= cur_accu_dis26;
                    pre_accu_dis27 <= cur_accu_dis27;
                    pre_accu_dis28 <= cur_accu_dis28;
                    pre_accu_dis29 <= cur_accu_dis29;
                    pre_accu_dis30 <= cur_accu_dis30;
                    pre_accu_dis31 <= cur_accu_dis31;
                    pre_accu_dis32 <= cur_accu_dis32;
                    pre_accu_dis33 <= cur_accu_dis33;
                    pre_accu_dis34 <= cur_accu_dis34;
                    pre_accu_dis35 <= cur_accu_dis35;
                    pre_accu_dis36 <= cur_accu_dis36;
                    pre_accu_dis37 <= cur_accu_dis37;
                    pre_accu_dis38 <= cur_accu_dis38;
                    pre_accu_dis39 <= cur_accu_dis39;
                    pre_accu_dis40 <= cur_accu_dis40;
                    pre_accu_dis41 <= cur_accu_dis41;
                    pre_accu_dis42 <= cur_accu_dis42;
                    pre_accu_dis43 <= cur_accu_dis43;
                    pre_accu_dis44 <= cur_accu_dis44;
                    pre_accu_dis45 <= cur_accu_dis45;
                    pre_accu_dis46 <= cur_accu_dis46;
                    pre_accu_dis47 <= cur_accu_dis47;
                    pre_accu_dis48 <= cur_accu_dis48;
                    pre_accu_dis49 <= cur_accu_dis49;
                    pre_accu_dis50 <= cur_accu_dis50;
                    pre_accu_dis51 <= cur_accu_dis51;
                    pre_accu_dis52 <= cur_accu_dis52;
                    pre_accu_dis53 <= cur_accu_dis53;
                    pre_accu_dis54 <= cur_accu_dis54;
                    pre_accu_dis55 <= cur_accu_dis55;
                    pre_accu_dis56 <= cur_accu_dis56;
                    pre_accu_dis57 <= cur_accu_dis57;
                    pre_accu_dis58 <= cur_accu_dis58;
                    pre_accu_dis59 <= cur_accu_dis59;
                    pre_accu_dis60 <= cur_accu_dis60;
                    pre_accu_dis61 <= cur_accu_dis61;
                    pre_accu_dis62 <= cur_accu_dis62;
                    pre_accu_dis63 <= cur_accu_dis63;
                end
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_sur <= 0;
        end
        else begin
            if (in_vld) begin
                do_sur[0] <= do_sur_tmp0;
                do_sur[1] <= do_sur_tmp1;
                do_sur[2] <= do_sur_tmp2;
                do_sur[3] <= do_sur_tmp3;
                do_sur[4] <= do_sur_tmp4;
                do_sur[5] <= do_sur_tmp5;
                do_sur[6] <= do_sur_tmp6;
                do_sur[7] <= do_sur_tmp7;
                do_sur[8] <= do_sur_tmp8;
                do_sur[9] <= do_sur_tmp9;
                do_sur[10] <= do_sur_tmp10;
                do_sur[11] <= do_sur_tmp11;
                do_sur[12] <= do_sur_tmp12;
                do_sur[13] <= do_sur_tmp13;
                do_sur[14] <= do_sur_tmp14;
                do_sur[15] <= do_sur_tmp15;
                do_sur[16] <= do_sur_tmp16;
                do_sur[17] <= do_sur_tmp17;
                do_sur[18] <= do_sur_tmp18;
                do_sur[19] <= do_sur_tmp19;
                do_sur[20] <= do_sur_tmp20;
                do_sur[21] <= do_sur_tmp21;
                do_sur[22] <= do_sur_tmp22;
                do_sur[23] <= do_sur_tmp23;
                do_sur[24] <= do_sur_tmp24;
                do_sur[25] <= do_sur_tmp25;
                do_sur[26] <= do_sur_tmp26;
                do_sur[27] <= do_sur_tmp27;
                do_sur[28] <= do_sur_tmp28;
                do_sur[29] <= do_sur_tmp29;
                do_sur[30] <= do_sur_tmp30;
                do_sur[31] <= do_sur_tmp31;
                do_sur[32] <= do_sur_tmp32;
                do_sur[33] <= do_sur_tmp33;
                do_sur[34] <= do_sur_tmp34;
                do_sur[35] <= do_sur_tmp35;
                do_sur[36] <= do_sur_tmp36;
                do_sur[37] <= do_sur_tmp37;
                do_sur[38] <= do_sur_tmp38;
                do_sur[39] <= do_sur_tmp39;
                do_sur[40] <= do_sur_tmp40;
                do_sur[41] <= do_sur_tmp41;
                do_sur[42] <= do_sur_tmp42;
                do_sur[43] <= do_sur_tmp43;
                do_sur[44] <= do_sur_tmp44;
                do_sur[45] <= do_sur_tmp45;
                do_sur[46] <= do_sur_tmp46;
                do_sur[47] <= do_sur_tmp47;
                do_sur[48] <= do_sur_tmp48;
                do_sur[49] <= do_sur_tmp49;
                do_sur[50] <= do_sur_tmp50;
                do_sur[51] <= do_sur_tmp51;
                do_sur[52] <= do_sur_tmp52;
                do_sur[53] <= do_sur_tmp53;
                do_sur[54] <= do_sur_tmp54;
                do_sur[55] <= do_sur_tmp55;
                do_sur[56] <= do_sur_tmp56;
                do_sur[57] <= do_sur_tmp57;
                do_sur[58] <= do_sur_tmp58;
                do_sur[59] <= do_sur_tmp59;
                do_sur[60] <= do_sur_tmp60;
                do_sur[61] <= do_sur_tmp61;
                do_sur[62] <= do_sur_tmp62;
                do_sur[63] <= do_sur_tmp63;
            end
        end
    end

    // align do_sur & do_sur_vld
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_sur_vld <= 0;
        end
        else begin
            if (in_vld) begin
                do_sur_vld <= in_vld;
            end
            else begin
                do_sur_vld <= 0;
            end
        end
    end





    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            small_en <= 0;
        end
        else begin
            if (in_vld) begin
                if (acs_cnt == (`SIGNAL_CODED_LEN - 1)) begin
                    small_en <= 1;
                end
            end
            else begin
                if (small_cnt == 62 && small_en) begin   // if small_cnt=62,run 63 clock
                    small_en <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            small_cnt <= 0;
        end
        else begin
            if (small_en) begin
                if (small_cnt == 62) begin
                    small_cnt <= 0;
                end
                if (small_cnt < 62) begin
                    small_cnt <= small_cnt + 1;
                end
            end
        end
    end


    // the input of SDS is dis_for_compare
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            small_dis_tmp0 <= 0;
            small_dis_tmp1 <= 0;
            small_state_tmp0 <= 0;
            small_state_tmp1 <= 0;
            smallest_vld <= 0;
        end
        else begin
            if (small_en) begin
                case(small_cnt)
                0:begin
                    small_dis_tmp0 <= dis_for_compare[0];
                    small_dis_tmp1 <= dis_for_compare[1];
                    small_state_tmp0 <= 0;
                    small_state_tmp1 <= 1;
                end
                62:begin
                    smallest_vld <= 1;
                end
                default:begin
                    small_dis_tmp0 <= smaller_dis;
                    small_dis_tmp1 <= dis_for_compare[small_cnt + 1];
                    small_state_tmp0 <= smaller_state;
                    small_state_tmp1 <= small_cnt + 1;
                end
                endcase
            end
            else begin
                small_dis_tmp0 <= 0;
                small_dis_tmp1 <= 0;
                small_state_tmp0 <= 0;
                small_state_tmp1 <= 0;
                smallest_vld <= 0;
            end
        end
    end

    // get the smallest distance & state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_smallest_state <= 0;
        end
        else begin
            if (smallest_vld) begin
                do_smallest_state <= smaller_state;
            end
        end
    end

    // align the do_smallest_vld & do_smallest_state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_smallest_vld <= 0;
        end
        else begin
            do_smallest_vld <= smallest_vld;
        end
    end

    // ----------------------------------------------------------------------
    // instantiate sub-module

    // instantiate 64 SUB_ACS
    //  use group0
    SUB_ACS U_SUB_ACS0(
        .di_branch_dis0(intmp00),       
        .di_branch_dis1(intmp07),
        .di_accu_dis0(pre_accu_dis0),
        .di_accu_dis1(pre_accu_dis1),
        .do_accu_dis(cur_accu_dis0),
        .do_sur(do_sur_tmp0)       
        );

    SUB_ACS U_SUB_ACS1(
        .di_branch_dis0(intmp04),
        .di_branch_dis1(intmp03),
        .di_accu_dis0(pre_accu_dis2),
        .di_accu_dis1(pre_accu_dis3),
        .do_accu_dis(cur_accu_dis1),
        .do_sur(do_sur_tmp1)
        );

    SUB_ACS U_SUB_ACS2(
        .di_branch_dis0(intmp01),
        .di_branch_dis1(intmp06),
        .di_accu_dis0(pre_accu_dis4),
        .di_accu_dis1(pre_accu_dis5),
        .do_accu_dis(cur_accu_dis2),
        .do_sur(do_sur_tmp2)
        );

    SUB_ACS U_SUB_ACS3(
        .di_branch_dis0(intmp05),
        .di_branch_dis1(intmp02),
        .di_accu_dis0(pre_accu_dis6),
        .di_accu_dis1(pre_accu_dis7),
        .do_accu_dis(cur_accu_dis3),
        .do_sur(do_sur_tmp3)
        );

    SUB_ACS U_SUB_ACS4(
        .di_branch_dis0(intmp06),
        .di_branch_dis1(intmp01),
        .di_accu_dis0(pre_accu_dis8),
        .di_accu_dis1(pre_accu_dis9),
        .do_accu_dis(cur_accu_dis4),
        .do_sur(do_sur_tmp4)
        );

    SUB_ACS U_SUB_ACS5(
        .di_branch_dis0(intmp02),
        .di_branch_dis1(intmp05),
        .di_accu_dis0(pre_accu_dis10),
        .di_accu_dis1(pre_accu_dis11),
        .do_accu_dis(cur_accu_dis5),
        .do_sur(do_sur_tmp5)
        );

    SUB_ACS U_SUB_ACS6(
        .di_branch_dis0(intmp07),
        .di_branch_dis1(intmp00),
        .di_accu_dis0(pre_accu_dis12),
        .di_accu_dis1(pre_accu_dis13),
        .do_accu_dis(cur_accu_dis6),
        .do_sur(do_sur_tmp6)
        );

    SUB_ACS U_SUB_ACS7(
        .di_branch_dis0(intmp03),
        .di_branch_dis1(intmp04),
        .di_accu_dis0(pre_accu_dis14),
        .di_accu_dis1(pre_accu_dis15),
        .do_accu_dis(cur_accu_dis7),
        .do_sur(do_sur_tmp7)
        );


    // use group1
    SUB_ACS U_SUB_ACS8(
        .di_branch_dis0(intmp17),
        .di_branch_dis1(intmp10),
        .di_accu_dis0(pre_accu_dis16),
        .di_accu_dis1(pre_accu_dis17),
        .do_accu_dis(cur_accu_dis8),
        .do_sur(do_sur_tmp8)
        );

    SUB_ACS U_SUB_ACS9(
        .di_branch_dis0(intmp13),
        .di_branch_dis1(intmp14),
        .di_accu_dis0(pre_accu_dis18),
        .di_accu_dis1(pre_accu_dis19),
        .do_accu_dis(cur_accu_dis9),
        .do_sur(do_sur_tmp9)
        );

    SUB_ACS U_SUB_ACS10(
        .di_branch_dis0(intmp16),
        .di_branch_dis1(intmp11),
        .di_accu_dis0(pre_accu_dis20),
        .di_accu_dis1(pre_accu_dis21),
        .do_accu_dis(cur_accu_dis10),
        .do_sur(do_sur_tmp10)
        );
    
    SUB_ACS U_SUB_ACS11(
        .di_branch_dis0(intmp12),
        .di_branch_dis1(intmp15),
        .di_accu_dis0(pre_accu_dis22),
        .di_accu_dis1(pre_accu_dis23),
        .do_accu_dis(cur_accu_dis11),
        .do_sur(do_sur_tmp11)
        );

    SUB_ACS U_SUB_ACS12(
        .di_branch_dis0(intmp11),
        .di_branch_dis1(intmp16),
        .di_accu_dis0(pre_accu_dis24),
        .di_accu_dis1(pre_accu_dis25),
        .do_accu_dis(cur_accu_dis12),
        .do_sur(do_sur_tmp12)
        );

    SUB_ACS U_SUB_ACS13(
        .di_branch_dis0(intmp15),
        .di_branch_dis1(intmp12),
        .di_accu_dis0(pre_accu_dis26),
        .di_accu_dis1(pre_accu_dis27),
        .do_accu_dis(cur_accu_dis13),
        .do_sur(do_sur_tmp13)
        );

    SUB_ACS U_SUB_ACS14(
        .di_branch_dis0(intmp10),
        .di_branch_dis1(intmp17),
        .di_accu_dis0(pre_accu_dis28),
        .di_accu_dis1(pre_accu_dis29),
        .do_accu_dis(cur_accu_dis14),
        .do_sur(do_sur_tmp14)
        );

    SUB_ACS U_SUB_ACS15(
        .di_branch_dis0(intmp14),
        .di_branch_dis1(intmp13),
        .di_accu_dis0(pre_accu_dis30),
        .di_accu_dis1(pre_accu_dis31),
        .do_accu_dis(cur_accu_dis15),
        .do_sur(do_sur_tmp15)
        );


    // use group2
    SUB_ACS U_SUB_ACS16(
        .di_branch_dis0(intmp23),
        .di_branch_dis1(intmp24),
        .di_accu_dis0(pre_accu_dis32),
        .di_accu_dis1(pre_accu_dis33),
        .do_accu_dis(cur_accu_dis16),
        .do_sur(do_sur_tmp16)
        );

    SUB_ACS U_SUB_ACS17(
        .di_branch_dis0(intmp27),
        .di_branch_dis1(intmp20),
        .di_accu_dis0(pre_accu_dis34),
        .di_accu_dis1(pre_accu_dis35),
        .do_accu_dis(cur_accu_dis17),
        .do_sur(do_sur_tmp17)
        );

    SUB_ACS U_SUB_ACS18(
        .di_branch_dis0(intmp22),
        .di_branch_dis1(intmp25),
        .di_accu_dis0(pre_accu_dis36),
        .di_accu_dis1(pre_accu_dis37),
        .do_accu_dis(cur_accu_dis18),
        .do_sur(do_sur_tmp18)
        );

    SUB_ACS U_SUB_ACS19(
        .di_branch_dis0(intmp26),
        .di_branch_dis1(intmp21),
        .di_accu_dis0(pre_accu_dis38),
        .di_accu_dis1(pre_accu_dis39),
        .do_accu_dis(cur_accu_dis19),
        .do_sur(do_sur_tmp19)
        );

    SUB_ACS U_SUB_ACS20(
        .di_branch_dis0(intmp25),
        .di_branch_dis1(intmp22),
        .di_accu_dis0(pre_accu_dis40),
        .di_accu_dis1(pre_accu_dis41),
        .do_accu_dis(cur_accu_dis20),
        .do_sur(do_sur_tmp20)
        );

    SUB_ACS U_SUB_ACS21(
        .di_branch_dis0(intmp21),
        .di_branch_dis1(intmp26),
        .di_accu_dis0(pre_accu_dis42),
        .di_accu_dis1(pre_accu_dis43),
        .do_accu_dis(cur_accu_dis21),
        .do_sur(do_sur_tmp21)
        );

    SUB_ACS U_SUB_ACS22(
        .di_branch_dis0(intmp24),
        .di_branch_dis1(intmp23),
        .di_accu_dis0(pre_accu_dis44),
        .di_accu_dis1(pre_accu_dis45),
        .do_accu_dis(cur_accu_dis22),
        .do_sur(do_sur_tmp22)
        );

    SUB_ACS U_SUB_ACS23(
        .di_branch_dis0(intmp20),
        .di_branch_dis1(intmp27),
        .di_accu_dis0(pre_accu_dis46),
        .di_accu_dis1(pre_accu_dis47),
        .do_accu_dis(cur_accu_dis23),
        .do_sur(do_sur_tmp23)
        );

    //use group3
    SUB_ACS U_SUB_ACS24(
        .di_branch_dis0(intmp34),
        .di_branch_dis1(intmp33),
        .di_accu_dis0(pre_accu_dis48),
        .di_accu_dis1(pre_accu_dis49),
        .do_accu_dis(cur_accu_dis24),
        .do_sur(do_sur_tmp24)
        );

    SUB_ACS U_SUB_ACS25(
        .di_branch_dis0(intmp30),
        .di_branch_dis1(intmp37),
        .di_accu_dis0(pre_accu_dis50),
        .di_accu_dis1(pre_accu_dis51),
        .do_accu_dis(cur_accu_dis25),
        .do_sur(do_sur_tmp25)
        );

    SUB_ACS U_SUB_ACS26(
        .di_branch_dis0(intmp35),
        .di_branch_dis1(intmp32),
        .di_accu_dis0(pre_accu_dis52),
        .di_accu_dis1(pre_accu_dis53),
        .do_accu_dis(cur_accu_dis26),
        .do_sur(do_sur_tmp26)
        );

    SUB_ACS U_SUB_ACS27(
        .di_branch_dis0(intmp31),
        .di_branch_dis1(intmp36),
        .di_accu_dis0(pre_accu_dis54),
        .di_accu_dis1(pre_accu_dis55),
        .do_accu_dis(cur_accu_dis27),
        .do_sur(do_sur_tmp27)
        );

    SUB_ACS U_SUB_ACS28(
        .di_branch_dis0(intmp32),
        .di_branch_dis1(intmp35),
        .di_accu_dis0(pre_accu_dis56),
        .di_accu_dis1(pre_accu_dis57),
        .do_accu_dis(cur_accu_dis28),
        .do_sur(do_sur_tmp28)
        );

    SUB_ACS U_SUB_ACS29(
        .di_branch_dis0(intmp36),
        .di_branch_dis1(intmp31),
        .di_accu_dis0(pre_accu_dis58),
        .di_accu_dis1(pre_accu_dis59),
        .do_accu_dis(cur_accu_dis29),
        .do_sur(do_sur_tmp29)
        );

    SUB_ACS U_SUB_ACS30(
        .di_branch_dis0(intmp33),
        .di_branch_dis1(intmp34),
        .di_accu_dis0(pre_accu_dis60),
        .di_accu_dis1(pre_accu_dis61),
        .do_accu_dis(cur_accu_dis30),
        .do_sur(do_sur_tmp30)
        );

    SUB_ACS U_SUB_ACS31(
        .di_branch_dis0(intmp37),
        .di_branch_dis1(intmp30),
        .di_accu_dis0(pre_accu_dis62),
        .di_accu_dis1(pre_accu_dis63),
        .do_accu_dis(cur_accu_dis31),
        .do_sur(do_sur_tmp31)
        );

    // use group4
    SUB_ACS U_SUB_ACS32(
        .di_branch_dis0(intmp47),
        .di_branch_dis1(intmp40),
        .di_accu_dis0(pre_accu_dis0),
        .di_accu_dis1(pre_accu_dis1),
        .do_accu_dis(cur_accu_dis32),
        .do_sur(do_sur_tmp32)
        );

    SUB_ACS U_SUB_ACS33(
        .di_branch_dis0(intmp43),
        .di_branch_dis1(intmp44),
        .di_accu_dis0(pre_accu_dis2),
        .di_accu_dis1(pre_accu_dis3),
        .do_accu_dis(cur_accu_dis33),
        .do_sur(do_sur_tmp33)
        );

    SUB_ACS U_SUB_ACS34(
        .di_branch_dis0(intmp46),
        .di_branch_dis1(intmp41),
        .di_accu_dis0(pre_accu_dis4),
        .di_accu_dis1(pre_accu_dis5),
        .do_accu_dis(cur_accu_dis34),
        .do_sur(do_sur_tmp34)
        );

    SUB_ACS U_SUB_ACS35(
        .di_branch_dis0(intmp42),
        .di_branch_dis1(intmp45),
        .di_accu_dis0(pre_accu_dis6),
        .di_accu_dis1(pre_accu_dis7),
        .do_accu_dis(cur_accu_dis35),
        .do_sur(do_sur_tmp35)
        );

    SUB_ACS U_SUB_ACS36(
        .di_branch_dis0(intmp41),
        .di_branch_dis1(intmp46),
        .di_accu_dis0(pre_accu_dis8),
        .di_accu_dis1(pre_accu_dis9),
        .do_accu_dis(cur_accu_dis36),
        .do_sur(do_sur_tmp36)
        );

    SUB_ACS U_SUB_ACS37(
        .di_branch_dis0(intmp45),
        .di_branch_dis1(intmp42),
        .di_accu_dis0(pre_accu_dis10),
        .di_accu_dis1(pre_accu_dis11),
        .do_accu_dis(cur_accu_dis37),
        .do_sur(do_sur_tmp37)
        );

    SUB_ACS U_SUB_ACS38(
        .di_branch_dis0(intmp40),
        .di_branch_dis1(intmp47),
        .di_accu_dis0(pre_accu_dis12),
        .di_accu_dis1(pre_accu_dis13),
        .do_accu_dis(cur_accu_dis38),
        .do_sur(do_sur_tmp38)
        );

    SUB_ACS U_SUB_ACS39(
        .di_branch_dis0(intmp44),
        .di_branch_dis1(intmp43),
        .di_accu_dis0(pre_accu_dis14),
        .di_accu_dis1(pre_accu_dis15),
        .do_accu_dis(cur_accu_dis39),
        .do_sur(do_sur_tmp39)
        );

    // use group5
    SUB_ACS U_SUB_ACS40(
        .di_branch_dis0(intmp50),
        .di_branch_dis1(intmp57),
        .di_accu_dis0(pre_accu_dis16),
        .di_accu_dis1(pre_accu_dis17),
        .do_accu_dis(cur_accu_dis40),
        .do_sur(do_sur_tmp40)
        );

    SUB_ACS U_SUB_ACS41(
        .di_branch_dis0(intmp54),
        .di_branch_dis1(intmp53),
        .di_accu_dis0(pre_accu_dis18),
        .di_accu_dis1(pre_accu_dis19),
        .do_accu_dis(cur_accu_dis41),
        .do_sur(do_sur_tmp41)
        );

    SUB_ACS U_SUB_ACS42(
        .di_branch_dis0(intmp51),
        .di_branch_dis1(intmp56),
        .di_accu_dis0(pre_accu_dis20),
        .di_accu_dis1(pre_accu_dis21),
        .do_accu_dis(cur_accu_dis42),
        .do_sur(do_sur_tmp42)
        );

    SUB_ACS U_SUB_ACS43(
        .di_branch_dis0(intmp55),
        .di_branch_dis1(intmp52),
        .di_accu_dis0(pre_accu_dis22),
        .di_accu_dis1(pre_accu_dis23),
        .do_accu_dis(cur_accu_dis43),
        .do_sur(do_sur_tmp43)
        );

    SUB_ACS U_SUB_ACS44(
        .di_branch_dis0(intmp56),
        .di_branch_dis1(intmp51),
        .di_accu_dis0(pre_accu_dis24),
        .di_accu_dis1(pre_accu_dis25),
        .do_accu_dis(cur_accu_dis44),
        .do_sur(do_sur_tmp44)
        );

    SUB_ACS U_SUB_ACS45(
        .di_branch_dis0(intmp52),
        .di_branch_dis1(intmp55),
        .di_accu_dis0(pre_accu_dis26),
        .di_accu_dis1(pre_accu_dis27),
        .do_accu_dis(cur_accu_dis45),
        .do_sur(do_sur_tmp45)
        );

    SUB_ACS U_SUB_ACS46(
        .di_branch_dis0(intmp57),
        .di_branch_dis1(intmp50),
        .di_accu_dis0(pre_accu_dis28),
        .di_accu_dis1(pre_accu_dis29),
        .do_accu_dis(cur_accu_dis46),
        .do_sur(do_sur_tmp46)
        );

    SUB_ACS U_SUB_ACS47(
        .di_branch_dis0(intmp53),
        .di_branch_dis1(intmp54),
        .di_accu_dis0(pre_accu_dis30),
        .di_accu_dis1(pre_accu_dis31),
        .do_accu_dis(cur_accu_dis47),
        .do_sur(do_sur_tmp47)
        );

    // use group6
    SUB_ACS U_SUB_ACS48(
        .di_branch_dis0(intmp64),
        .di_branch_dis1(intmp63),
        .di_accu_dis0(pre_accu_dis32),
        .di_accu_dis1(pre_accu_dis33),
        .do_accu_dis(cur_accu_dis48),
        .do_sur(do_sur_tmp48)
        );

    SUB_ACS U_SUB_ACS49(
        .di_branch_dis0(intmp60),
        .di_branch_dis1(intmp67),
        .di_accu_dis0(pre_accu_dis34),
        .di_accu_dis1(pre_accu_dis35),
        .do_accu_dis(cur_accu_dis49),
        .do_sur(do_sur_tmp49)
        );

    SUB_ACS U_SUB_ACS50(
        .di_branch_dis0(intmp65),
        .di_branch_dis1(intmp62),
        .di_accu_dis0(pre_accu_dis36),
        .di_accu_dis1(pre_accu_dis37),
        .do_accu_dis(cur_accu_dis50),
        .do_sur(do_sur_tmp50)
        );

    SUB_ACS U_SUB_ACS51(
        .di_branch_dis0(intmp61),
        .di_branch_dis1(intmp66),
        .di_accu_dis0(pre_accu_dis38),
        .di_accu_dis1(pre_accu_dis39),
        .do_accu_dis(cur_accu_dis51),
        .do_sur(do_sur_tmp51)
        );

    SUB_ACS U_SUB_ACS52(
        .di_branch_dis0(intmp62),
        .di_branch_dis1(intmp65),
        .di_accu_dis0(pre_accu_dis40),
        .di_accu_dis1(pre_accu_dis41),
        .do_accu_dis(cur_accu_dis52),
        .do_sur(do_sur_tmp52)
        );

    SUB_ACS U_SUB_ACS53(
        .di_branch_dis0(intmp66),
        .di_branch_dis1(intmp61),
        .di_accu_dis0(pre_accu_dis42),
        .di_accu_dis1(pre_accu_dis43),
        .do_accu_dis(cur_accu_dis53),
        .do_sur(do_sur_tmp53)
        );

    SUB_ACS U_SUB_ACS54(
        .di_branch_dis0(intmp63),
        .di_branch_dis1(intmp64),
        .di_accu_dis0(pre_accu_dis44),
        .di_accu_dis1(pre_accu_dis45),
        .do_accu_dis(cur_accu_dis54),
        .do_sur(do_sur_tmp54)
        );

    SUB_ACS U_SUB_ACS55(
        .di_branch_dis0(intmp67),
        .di_branch_dis1(intmp60),
        .di_accu_dis0(pre_accu_dis46),
        .di_accu_dis1(pre_accu_dis47),
        .do_accu_dis(cur_accu_dis55),
        .do_sur(do_sur_tmp55)
        );

    // use group7
    SUB_ACS U_SUB_ACS56(
        .di_branch_dis0(intmp73),
        .di_branch_dis1(intmp74),
        .di_accu_dis0(pre_accu_dis48),
        .di_accu_dis1(pre_accu_dis49),
        .do_accu_dis(cur_accu_dis56),
        .do_sur(do_sur_tmp56)
        );

    SUB_ACS U_SUB_ACS57(
        .di_branch_dis0(intmp77),
        .di_branch_dis1(intmp70),
        .di_accu_dis0(pre_accu_dis50),
        .di_accu_dis1(pre_accu_dis51),
        .do_accu_dis(cur_accu_dis57),
        .do_sur(do_sur_tmp57)
        );

    SUB_ACS U_SUB_ACS58(
        .di_branch_dis0(intmp72),
        .di_branch_dis1(intmp75),
        .di_accu_dis0(pre_accu_dis52),
        .di_accu_dis1(pre_accu_dis53),
        .do_accu_dis(cur_accu_dis58),
        .do_sur(do_sur_tmp58)
        );

    SUB_ACS U_SUB_ACS59(
        .di_branch_dis0(intmp76),
        .di_branch_dis1(intmp71),
        .di_accu_dis0(pre_accu_dis54),
        .di_accu_dis1(pre_accu_dis55),
        .do_accu_dis(cur_accu_dis59),
        .do_sur(do_sur_tmp59)
        );

    SUB_ACS U_SUB_ACS60(
        .di_branch_dis0(intmp75),
        .di_branch_dis1(intmp72),
        .di_accu_dis0(pre_accu_dis56),
        .di_accu_dis1(pre_accu_dis57),
        .do_accu_dis(cur_accu_dis60),
        .do_sur(do_sur_tmp60)
        );

    SUB_ACS U_SUB_ACS61(
        .di_branch_dis0(intmp71),
        .di_branch_dis1(intmp76),
        .di_accu_dis0(pre_accu_dis58),
        .di_accu_dis1(pre_accu_dis59),
        .do_accu_dis(cur_accu_dis61),
        .do_sur(do_sur_tmp61)
        );

    SUB_ACS U_SUB_ACS62(
        .di_branch_dis0(intmp74),
        .di_branch_dis1(intmp73),
        .di_accu_dis0(pre_accu_dis60),
        .di_accu_dis1(pre_accu_dis61),
        .do_accu_dis(cur_accu_dis62),
        .do_sur(do_sur_tmp62)
        );

    SUB_ACS U_SUB_ACS63(
        .di_branch_dis0(intmp70),
        .di_branch_dis1(intmp77),
        .di_accu_dis0(pre_accu_dis62),
        .di_accu_dis1(pre_accu_dis63),
        .do_accu_dis(cur_accu_dis63),
        .do_sur(do_sur_tmp63)
        );

    // instantiate the SDS Unit
    SDS U_SDS(
        .di_dis0(small_dis_tmp0),           // small_dis_tmp0
        .di_dis1(small_dis_tmp1),           // small_dis_tmp1
        .di_state0(small_state_tmp0),         // small_state_tmp0
        .di_state1(small_state_tmp1),         // small_state_tmp1
        .do_dis(smaller_dis),            // smaller_dis
        .do_state(smaller_state)           // smaller_state
        );

endmodule
