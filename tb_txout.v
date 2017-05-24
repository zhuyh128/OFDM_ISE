`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:38:51 12/12/2016
// Design Name:   TXOUT
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_txout.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TXOUT
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module tb_txout;

	// Inputs
	reg clk;
	reg new_frame;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	TXOUT uut (
		.clk(clk), 
		.new_frame(new_frame), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);
	
	integer  txout_output_re;
   integer  txout_output_im;
	
/*	integer  in_data_re;								//Modified by baiyf
	integer  in_data_im;
	integer  read_cnt;
	integer  frame_num=0;
*/ 
   reg  [11:0]  inputdata_re  [0:3263];
   reg  [11:0]  inputdata_im  [0:3263];

	initial begin
		// Initialize Inputs
		clk = 0;
		new_frame = 1;
		rst = 0;
		di_re = 0;
		di_im = 0;
		di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		txout_output_re = $fopen("./debug_data/txout_output_re.dat", "w");
      txout_output_im = $fopen("./debug_data/txout_output_im.dat", "w");
		
/*		in_data_re = $fopen("./debug_data/pfu_output_re.dat","r+b");				//Modified by baiyf
		in_data_im = $fopen("./debug_data/pfu_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end*/
		
      $readmemb("./debug_data/pfu_output_re.dat", inputdata_re);
      $readmemb("./debug_data/pfu_output_im.dat", inputdata_im);
      new_frame = 0;
    end

    //--------------------------------------------------------------------------
    // input

    always #(`CLK_PERIOD/2) clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE0 = 5,
                 VALUE1 = 30,
                 VALUE2 = VALUE1 + 3264 - 1;

    always @(posedge clk) begin
			  if (cnt < MAX) begin
					cnt <= cnt + 1;
			  end
		     if (cnt == VALUE0) begin			//Modified by baiyf
					new_frame <= 1;
			  end
			  else begin
					new_frame <= 0;
			  end
			  if (cnt == MAX) begin
					$fclose(txout_output_re);
					$fclose(txout_output_im);
					$stop;
			  end
    end

    integer  indx;
    always @(posedge clk) begin
			  if (cnt >= VALUE1 && cnt <= VALUE2) begin
					indx <= indx + 1;
			  end
			  else begin
					indx <= 0;
			  end
    end

    always @(posedge clk) begin
			  di_re <= inputdata_re[indx];
			  di_im <= inputdata_im[indx];
    end

    always @(posedge clk) begin
			  if (cnt >= VALUE1 && cnt <= VALUE2) begin
					di_vld <= 1;
			  end
			  else begin
					di_vld <= 0;
			  end
    end

    //--------------------------------------------------------------------------
    // save the result into file

    always @(posedge clk) begin
        if (do_vld) begin
            $fdisplay(txout_output_re, "%b", do_re);
            $fdisplay(txout_output_im, "%b", do_im);
        end
    end
	 
/*	 always												//Modified by baiyf
	 begin
		 wait((cnt==MAX)&&(frame_num<`NF-1))
		 begin
				new_frame=1;
				#1000 for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
				    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
				end
				for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
				    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
				end
				new_frame=0;
				frame_num=frame_num+1;
				
		 end
	 end
*/
		
endmodule
