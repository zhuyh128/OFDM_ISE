`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2016 09:30:31 AM
// Design Name: 
// Module Name: OPG(Origin Payload Generater)
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: sub-module of OBG
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
// 
//% the module read out origin payload from ROM for channel decoder
//% actually, it should be moved to FMAC module 

module OPG(
	 input done_rst,
    input clk,          //% working clock
    input rst,          //% reset
    input rd_en,        //% new frame 
    output reg do,      //% origin payload data output
    output reg do_vld,   //% output origin payload data valid
	 output reg done_flag
    );

//==============================================================================
// Main Body of Code

    //------------------------------------------------
    // detect posedge of rd_en
    reg         rd_en_r1;
    reg         rd_en_r2;
    wire        rd_en_posedge;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            rd_en_r1 <= 0;
            rd_en_r2 <= 0;
        end
        else begin
            rd_en_r1 <= rd_en;
            rd_en_r2 <= rd_en_r1;
        end
    end

    assign rd_en_posedge = rd_en_r1 & (!rd_en_r2);


    //----------------------------------------------
    // generate address of ROM
    reg          addr_en;
    reg  [12:0]  addr;
    wire         dout;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            addr_en <= 0;
        end
        else begin
            if (rd_en_posedge) begin
                addr_en <= 1;
            end
            else if (addr == 13'd4319) begin
                addr_en <= 0;
            end
            else begin
                addr_en <= addr_en;
            end
        end
    end

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            addr <= 13'd0;
        end
        else begin
            if (addr_en) begin
                addr <= addr + 1;
            end
            else begin
                addr <= 13'd0;
            end
        end
    end

    //----------------------------------------------
    // generate output

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            do <= 0;
        end
        else begin
            do <= dout;
        end
    end

    reg     dout_vld_pre;
    reg     dout_vld;

    always @(posedge clk or posedge rst or posedge done_rst) begin
        if (rst||done_rst) begin
            // reset
            dout_vld_pre <= 0;
            dout_vld <= 0;
            do_vld <= 0;
        end
        else begin
            dout_vld_pre <= addr_en;
            dout_vld <= dout_vld_pre;
            do_vld <= dout_vld;
        end
    end
	
	 always @(posedge clk or posedge rst ) begin							//Modified by baiyf
	     if(rst) begin
		      done_flag<=0;
		  end
		  else begin
		      if(addr==4321)begin
					done_flag<=1;
				end
		  end
	 end
    // -------------------------------------------------------------------------

    // OPG_ROM U_OPG_ROM (
    //     .clka(clk),    // input wire clka
    //     .addra(addr),  // input wire [12 : 0] addra
    //     .douta(dout)  // output wire [0 : 0] douta
    // );
    // 
    ROM_OPG U_ROM_OPG (
        .clka(clk),    // input wire clka
        .addra(addr),  // input wire [12 : 0] addra
        .douta(dout)  // output wire [0 : 0] douta
    );

endmodule
