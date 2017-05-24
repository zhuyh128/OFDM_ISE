`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:37:18 12/12/2016
// Design Name:   PFU
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_pfu.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PFU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_pfu;

	// Inputs
	reg clk;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	PFU uut (
		.clk(clk), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);

	integer  pfu_output_re;
   integer  pfu_output_im;
	
/*	integer	in_data_re;							//Modified by baiyf
	integer  in_data_im;
	integer	frame_num=0;			
	integer  read_cnt;	
	reg	new_frame;*/

   reg  [11:0]  input_re  [0:3264-1];
   reg  [11:0]  input_im  [0:3264-1];
	
	initial begin
		// Initialize Inputs
		clk = 0;
		di_re = 0;
		di_im = 0;
		di_vld = 0;
//		new_frame=1;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		pfu_output_re = $fopen("./debug_data/pfu_output_re.dat", "w");
      pfu_output_im = $fopen("./debug_data/pfu_output_im.dat", "w");
		
/*		in_data_re = $fopen("./debug_data/ifft_cp_output_re.dat","r+b");			//Modified by baiyf
		in_data_im = $fopen("./debug_data/ifft_cp_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<3808;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",input_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<3808;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",input_im[read_cnt]);
		end*/
		
      $readmemb("./debug_data/ifft_cp_output_re.dat", input_re);
      $readmemb("./debug_data/ifft_cp_output_im.dat", input_im);
//		new_frame=0;
    end

    //---------------------------------------------------------------------------
    
     always #(`CLK_PERIOD/2) clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 5000,
                 VALUE0 = 5,
                 VALUE1 = 30,
                 VALUE2 = VALUE1 + 3264 - 1;

    always @(posedge clk) begin
			  if (cnt < MAX) begin
					cnt <= cnt + 1;
			  end
			  if (cnt == MAX) begin
					$fclose(pfu_output_re);
					$fclose(pfu_output_im);
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
			  di_re <= input_re[indx];
			  di_im <= input_im[indx];
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

    always @(posedge clk) begin
        if (do_vld) begin
            $fdisplay(pfu_output_re, "%b", do_re);
            $fdisplay(pfu_output_im, "%b", do_im);
        end
    end
	 
/*	 always																			//Modified by baiyf
	 begin
		 wait((cnt==MAX)&&(frame_num<`NF-1))
		 begin
			new_frame=1;
			#1000	for(read_cnt=0;read_cnt<3808;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_re,"%b",input_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<3808;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_im,"%b",input_im[read_cnt]);
			end
			new_frame=0;
			frame_num=frame_num+1;
		 end
	 end
*/
endmodule
