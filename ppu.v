//% @file ppu.v
//% @brief Implementation file of Fake Payload Padding Unit(PPU) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2016-03-07

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Payload Padding Unit(PPU) generate the padding bits of payload
//% 
//% @note length of input bits is 8640, and the padding bits is the first 960 
//%       bits of it.
module PPU (
	 input					done_rst,
    input               clk,        //% working clock
    input               rst,        //% reset, active high
    input               di,         //% input encoded data of payload
    input               di_vld,     //% input data valid
    output  reg         do,         //% output data
    output  reg         do_vld,     //% output data valid
    output  reg  [3:0]  do_sym_num,  // number of payload symbol = 5
	 output  reg         done_flag
	 );

//==============================================================================
// Main Body of Code
	 
	 reg neg_do_vld;						//Modified by baiyf
	 
    //----------------------------------
    // write first 960 bits into FIFO

    reg  [13:0]  di_cnt;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            di_cnt <= 14'd0;
        end
        else begin
            if (di_vld) begin
                di_cnt <= di_cnt + 1;
            end
            else begin
                di_cnt <= 14'd0;
            end	
        end
    end

    reg  din;
    reg  wr_en;
    wire full;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            din <= 0;
        end
        else begin
            din <= di;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            wr_en <= 0;
        end
        else begin
            if (!full && di_vld && di_cnt <= 14'd959) begin
                wr_en <= 1;
            end
            else begin
                wr_en <= 0;
            end
        end
    end

    //----------------------------------------
    // read out when finished

    reg  rd_en;
    wire dout;
    wire empty;
    wire valid;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (di_cnt == 14'd8638) 
				begin                    
                rd_en <= 1;
            end
            if (empty) begin
                rd_en <= 0;
            end
        end
    end

    //----------------------------------------
    // generate output
    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            do_sym_num <= 0;
        end
        else begin
            if (di_vld) begin
                do_sym_num <= 4'd5;
            end
        end
    end

    reg  data;
    reg  data_vld;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            data <= 0;
            data_vld <= 0;
        end
        else begin
            data <= di;
            data_vld <= di_vld;
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            do <= 0;
            do_vld <= 0;
        end
        else begin
            if (data_vld) begin
                do <= data;
            end
            if (valid) begin
                do <= dout;
            end
            do_vld <= data_vld || valid;
        end
    end
	
	always @(posedge clk) begin														//Modified by baiyf
		neg_do_vld <= !do_vld;
	end
	
	always @(posedge neg_do_vld or posedge done_rst or posedge rst) begin
		if(rst||done_rst) begin
			done_flag <= 0;
		end
		else begin
			done_flag <= 1;
		end
	end
	
    //----------------------------------------
    PPU_FIFO U_PPU_FIFO (
        .wr_clk(clk),  // input wire wr_clk
        .rd_clk(clk),  // input wire rd_clk
        .rst(rst),      // input wire rst
        .din(din),      // input wire [0 : 0] din
        .wr_en(wr_en),  // input wire wr_en
        .rd_en(rd_en),  // input wire rd_en
        .dout(dout),    // output wire [0 : 0] dout
        .full(full),    // output wire full
        .empty(empty),  // output wire empty
        .valid(valid)  // output wire valid
    );

endmodule