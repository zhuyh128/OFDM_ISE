//% @file ssg.v
//% @brief Implementation file of Signal Segment Generator(SSG) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-22

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Signal Segment Generator(SSG) finish the generation of signal segment.
//% 
//% The format of signal segment is:
//% 
//% MSB <---------------------------------> LSB
//% 
//% 4 bits + 16 btis + 4 bits + 4 bits + 4 bits
//% 
//% padding + length + type + rate + modulation
//% 
//% **Timing:**
//% 
//% 1. when input data is valid(di_vld), start to generate the signal segment.
//% 2. output the signal segment serially
//% 
//% @note output is LSB first
module SSG (
//	 input						  done_rst,
    input                    clk,       //% working clock
    input                    rst,       //% asynchronous reset, active high
    input        [15 : 0]    di_len,    //% length of PSDU
    input        [3  : 0]    di_type,   //% type of PSDU
    input                    di_vld,    //% data input valid
    
    output  reg  [5  : 0]    do_init,   //% last 6 bits of do
    output  reg              do,        //% original signal data output
    output  reg              do_vld     //% data otuput valid
//	 output  reg				  done_flag                  //job done
    );

//==============================================================================
// Local Parameter Declaration
    localparam    PADDING_WIDTH = 4;                    //% pad signal to 32 bits
    localparam    NUM_TOTAL_BITS = PADDING_WIDTH + 28;  //% 4 + 4 + 4 + 16 = 28
    localparam    INDX_WIDTH = 5;                       //% index max is 31
    localparam    MAX = NUM_TOTAL_BITS - 1;             //% MAX index to output

//==============================================================================
// Main Body of Code

    //------------------------------------------
    // generate the signal segment

    reg    [NUM_TOTAL_BITS-1 : 0]   signal_bits;    //% signal segment bits
    //% generate the signal bits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            signal_bits <= 0;
        end
        else begin
            signal_bits <= {4'b1111, di_len, di_type, `PCER, `MODM};
        end
    end

    //------------------------------------------
    // output

    reg     indx_en;                        //% output index count enable
    reg     [INDX_WIDTH-1 : 0]   indx;      //% output index
    //% get the output index enable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            indx_en <= 0;
        end
        else begin
            if (di_vld) begin
                indx_en <= 1;
            end
            else if (indx == MAX) begin
                indx_en <= 0;
            end
        end
    end

    //% get the output index
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            indx <= 0;
        end
        else begin
            if (indx_en && (indx < MAX)) begin  // incase of index exceeds the boundry
                indx <= indx + 1;
            end
            else begin
                indx <= 0;
            end
        end
    end

    //% data output serial
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            do <= signal_bits[indx];
        end
    end

    //% output the do_init
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_init <= 0;
        end
        else begin
            do_init <= signal_bits[MAX- : 6];   // do_inti has 6 bits
        end
    end

    //% get data output valid
    always @(posedge clk or posedge rst ) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            do_vld <= indx_en;
        end
    end
	 
/*	 always@(posedge clk or posedge rst) begin			//frame done flag  
	     if(rst) begin                                 //Modified by baiyf
		      done_flag<=0;
		  end
		  else begin
			  if(indx==MAX) begin
				#1	done_flag<=1;
			  end
		  end
	 end
*/
endmodule
