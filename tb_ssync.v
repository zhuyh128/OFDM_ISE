`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:46:39 12/13/2016
// Design Name:   SSYNC
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_ssync.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SSYNC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_ssync;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;
	wire [9:0] max_indx;
	wire max_indx_vld;

	// Instantiate the Unit Under Test (UUT)
	SSYNC uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld), 
		.max_indx(max_indx), 
		.max_indx_vld(max_indx_vld)
	);

	integer         ssync_output_re;
   integer         ssync_output_im;
   reg  [11:0]     inputdata_re  [0:9536-1]; // number of cfoc output data
   reg  [11:0]     inputdata_im  [0:9536-1];
		
/*	integer         in_data_re;			//Modified by baiyf
	integer         in_data_im;
	integer         frame_num=0;
	integer         read_cnt;*/

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di_re = 0;
		di_im = 0;
		di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		ssync_output_re = $fopen("./debug_data/ssync_output_re.dat", "w");
      ssync_output_im = $fopen("./debug_data/ssync_output_im.dat", "w");
      //$readmemb("../debug_data/pre_symbol_sync_re.dat", inputdata_re);
      //$readmemb("../debug_data/pre_symbol_sync_im.dat", inputdata_im);
			
      $readmemb("./debug_data/cfoc_output_re.dat", inputdata_re);				//Modified by baiyf
      $readmemb("./debug_data/cfoc_output_im.dat", inputdata_im);
/*		in_data_re = $fopen("./debug_data/cfoc_output_re.dat","r+b");
		in_data_im = $fopen("./debug_data/cfoc_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<9537;read_cnt=read_cnt+1) begin
			 $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<9537;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end*/
      rst = 0;

    end

    //--------------------------------------------------------------------------


    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 30000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 9536*3 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(ssync_output_re);
                $fclose(ssync_output_im);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    integer  indx;
    always @(posedge clk) begin
        if (rst) begin
            indx <= 0;
        end
        else begin
            // input valid every 3 clock cycle
            if (cnt >= VALUE1 && cnt < VALUE2 && cnt%3 == 1) begin
                indx <= indx + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            di_re <= 0;
            di_im <= 0;
        end
        else begin
            di_re <= inputdata_re[indx];
            di_im <= inputdata_im[indx];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            di_vld <= 0;
        end
        else begin
            // input is valid every 3 clock cycle
            if (cnt >= VALUE1 && cnt < VALUE2 && cnt%3 == 1) begin
                di_vld <= 1;
            end
            else begin
                di_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (do_vld) begin
            $fdisplay(ssync_output_re, "%b", do_re);
            $fdisplay(ssync_output_im, "%b", do_im);
        end
    end

/*	 always begin													//Modified by baiyf
	     wait((cnt==MAX)&&(frame_num<`NF-1)) begin
		      rst=1;
				
				#1000 for(read_cnt=0;read_cnt<9537;read_cnt=read_cnt+1) begin
				    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
				end
				for(read_cnt=0;read_cnt<9537;read_cnt=read_cnt+1) begin
				    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
				end
				rst=0;
				frame_num=frame_num+1;
		  end
	 end */
		
endmodule
