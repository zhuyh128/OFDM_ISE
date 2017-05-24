`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:42:42 12/13/2016
// Design Name:   CFOC
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_cfoc.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CFOC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_cfoc;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg cs_start;
	reg [17:0] cfo_estimated;
	reg cfo_estimated_vld;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	CFOC uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.cs_start(cs_start), 
		.cfo_estimated(cfo_estimated), 
		.cfo_estimated_vld(cfo_estimated_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);

	integer         cfoc_output_re;
   integer         cfoc_output_im;
   reg  [11:0]     inputdata_re  [0:11000-1];   // total samples: 
                                                // 1500 + 512*8 + (512+32)*6 = 8860
   reg  [11:0]     inputdata_im  [0:11000-1];
	
/*	integer         in_data_re;					//Modified by baiyf
	integer			 in_data_im;
	integer         frame_num=0;
	integer         read_cnt;*/
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di_re = 0;
		di_im = 0;
		cs_start = 0;
		cfo_estimated = 0;
		cfo_estimated_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		cfoc_output_re = $fopen("./debug_data/cfoc_output_re.dat", "w");
      cfoc_output_im = $fopen("./debug_data/cfoc_output_im.dat", "w");
/*		
		in_data_re = $fopen("./debug_data/cfoe_output_re.dat","r+b");			//Modified by baiyf
		in_data_im = $fopen("./debug_data/cfoe_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<11000;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<11000;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end*/
     $readmemb("./debug_data/cfoe_output_re.dat", inputdata_re);
     $readmemb("./debug_data/cfoe_output_im.dat", inputdata_im);
        rst = 0;

    end

    //--------------------------------------------------------------------------
    
    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 50000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 11000 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(cfoc_output_re);
                $fclose(cfoc_output_im);
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
            if (cnt >= VALUE1 && cnt < VALUE2) begin
                indx <= indx + 1;
            end
            else begin
                indx <= 0;
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
            cs_start <= 0;
        end
        else begin
            // packet start is the 1392th noise sample, cfoe_output.dat has extra invalid
            // 1550 samples, so cs_start = 1550 + 1392 + N = 3454
            if (indx == 3453) begin
                cs_start <= 1;
            end
            else begin
                cs_start <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cfo_estimated <= 0;
            cfo_estimated_vld <= 0;
        end
        else begin
            // according to CFOE module output result
            if (indx >= 4000) begin
                cfo_estimated <= 18'b11_1111_1111_1010_1100;
                cfo_estimated_vld <= 1;
            end
            else begin
                cfo_estimated <= 0;
                cfo_estimated_vld <= 0;
            end
        end
    end

    // number of cfoc output is more than C program samples, just for downstream logic simulation
    always @(posedge clk or posedge rst) begin
        if (do_vld) begin
            $fdisplay(cfoc_output_re, "%b", do_re);
            $fdisplay(cfoc_output_im, "%b", do_im);
        end
    end
	 
/*	 always begin												//Modified by baiyf
		wait((cnt==MAX)&&(frame_num<`NF-1))
		begin
			rst=1;
			#1000 for(read_cnt=0;read_cnt<11000;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<11000;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
			end
			rst=0;
			frame_num=frame_num+1;
		end
	 end
*/		
endmodule