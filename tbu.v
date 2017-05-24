`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 08/09/2016 09:02:49 AM
// Design Name: 
// Module Name: TBU
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implementation file of Trace Back Unit(TBU)
// 
// Dependencies: 1. input the sur_path(0 -> 95); 
//               2. input the traeceback start state(di_cur_state)
//               3. start tracebak
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
// 
//% Trace Back to get decode result
//
module TBU(
    input clk,                      //% working clock
    input rst,                      //% reset, active high
    input [63:0] di_sur_path,       //% input survive path, read from RAM, from DEPTH to first(time)
    input di_sur_path_vld,          //% input survive path data valid
    input [5:0] di_cur_state,       //% current state(traceback initial state is from SDS Unit)
    input di_cur_state_vld,         //% others are from the module self 
    output reg do_sur,              //% output the decode result
    output reg do_vld               //% output data valid
    );

    // =====================================================================
    // Main body of code
    
    
    // 1. save di_sur_path into RAM (480 samples)

    reg          wea;
    reg  [6 :0]  addra;
    reg  [63:0]  dina;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wea <= 0;
            addra <= 7'd127;
            dina <= 0;
        end
        else begin
            wea <= di_sur_path_vld;
            dina <= di_sur_path;
            if (di_sur_path_vld) begin
                addra <= addra + 1;
            end
        end
    end

    // 2. when di_cur_state is valid, read out di_sur_path from RAM

    reg  [6 :0]  addrb;
    wire [63:0]  doutb;
    reg doutb_vld;
    reg doutb_vld_tmp0;
    reg doutb_vld_tmp1;

    reg start_state_in_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            start_state_in_vld <= 0;
        end
        else begin
            if (di_cur_state_vld) begin
                start_state_in_vld <= 1;
            end
            if (start_state_in_vld && (addrb == 64)) begin
                start_state_in_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addrb <= 7'd96;
        end
        else begin
            if (start_state_in_vld) begin
                if (addrb == 7'd64) begin
                    addrb <= 7'd96;
                end
                else begin
                    addrb <= addrb - 1;
                end
            end
            else begin
                addrb <= 9'd96;
            end
        end
    end

    // get doutb_vld of RAM when di_cur_state is valid
    reg [4:0] read_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            read_cnt <= 0;
        end
        else begin
            if (doutb_vld) begin
                read_cnt <= read_cnt + 1;
            end
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            doutb_vld_tmp0 <= 0;
            doutb_vld_tmp1 <= 0;
            doutb_vld <= 0;
        end
        else begin
            if (start_state_in_vld) begin
                doutb_vld_tmp0 <= 1;
                doutb_vld_tmp1 <= doutb_vld_tmp0;
                doutb_vld <= doutb_vld_tmp1;
            end
            if (doutb_vld && (read_cnt == (`DEPTH - 1))) begin
                doutb_vld <= 0;
            end
        end
    end

    // 4. start to trace back when doutb_vld

    // get the start state of trace back
    reg [5:0] trace_start_state;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            trace_start_state <= 0;
        end
        else begin
            if (start_state_in_vld) begin
                trace_start_state <= di_cur_state;
            end
        end
    end


    // start to trace back
    reg [63:0] trace_sur_path;
    reg [5:0] trace_cur_state;
    wire trace_sur_value;    // decode output
    wire [5:0] trace_pre_state;

    reg [5:0] tb_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            tb_cnt <= 0;
        end
        else begin
            if (doutb_vld) begin
                if (tb_cnt == (`DEPTH - 1)) begin
                    tb_cnt <= 0;
                end
                if (tb_cnt < (`DEPTH - 1)) begin
                    tb_cnt <= tb_cnt + 1;
                end
            end
        end
    end

    reg [31:0] do_tmp;
    reg do_tmp_vld;
    reg [4:0] out_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            trace_sur_path <= 0;
            trace_cur_state <= 0;
            do_tmp <= 0;
        end
        else begin
            if (doutb_vld) begin
                case(tb_cnt)
                0:begin
                    trace_sur_path <= doutb;
                    trace_cur_state <= trace_start_state;
                end
                `DEPTH - 1:begin
                    do_tmp_vld <= 1;
                    do_tmp[(`DEPTH) - tb_cnt] <= trace_sur_value;
                    do_tmp[0] <= trace_sur_value;            // unuse
                    trace_sur_path <= doutb;
                    trace_cur_state <= trace_pre_state;
                end
                default:begin
                    trace_sur_path <= doutb;
                    trace_cur_state <= trace_pre_state;
                    do_tmp[(`DEPTH) - tb_cnt] <= trace_sur_value;
                end
                endcase               
            end
            if (do_tmp_vld && (out_cnt == (`DEPTH - 1))) begin
                do_tmp_vld <= 0;
            end
        end
    end

    // 5. get output when tracback finish

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt <= 0;
        end
        else begin
            if (do_tmp_vld) begin
                if (out_cnt == (`DEPTH - 1)) begin
                    out_cnt <= 0;
                end
                if (out_cnt < (`DEPTH - 1)) begin
                    out_cnt <= out_cnt + 1;
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
            if (do_tmp_vld) begin
                case(out_cnt)
                0:begin
                    do_sur <= trace_sur_value;
                end
                default:begin
                    do_sur <= do_tmp[out_cnt];                    
                end
                endcase

            end
            else begin
                do_sur <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            if (do_tmp_vld) begin
                do_vld <= do_tmp_vld;
            end
            else begin
                do_vld <= 0;
            end
        end
    end

    // -----------------------------------------------------------------
    // instantiate the sub module

    // instantiate the SUR_PATH_RAM ip core
    SUR_PATH_RAM U_SUR_PATH_RAM (
        .clka(clk),    // input wire clka
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [6 : 0] addra
        .dina(dina),    // input wire [63 : 0] dina
        .clkb(clk),    // input wire clkb
        .rstb(rst),    // input wire rstb
        .addrb(addrb),  // input wire [6 : 0] addrb
        .doutb(doutb)  // output wire [63 : 0] doutb
    );

    // instantiate the TRACE module
    TRACE U_TRACE(
        .di_sur_path(trace_sur_path),
        .di_cur_state(trace_cur_state),
        .do_sur(trace_sur_value),
        .do_pre_state(trace_pre_state)
        );


endmodule
