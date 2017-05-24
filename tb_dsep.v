`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:52:23 12/13/2016
// Design Name:   DSEP
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_dsep.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DSEP
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_dsep;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;
	reg [9:0] max_indx;
	reg max_indx_vld;

	// Outputs
	wire [11:0] do_preamble_re;
	wire [11:0] do_preamble_im;
	wire do_preamble_vld;
	wire [11:0] do_sigpld_re;
	wire [11:0] do_sigpld_im;
	wire do_sigpld_vld;

	// Instantiate the Unit Under Test (UUT)
	DSEP uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.max_indx(max_indx), 
		.max_indx_vld(max_indx_vld), 
		.do_preamble_re(do_preamble_re), 
		.do_preamble_im(do_preamble_im), 
		.do_preamble_vld(do_preamble_vld), 
		.do_sigpld_re(do_sigpld_re), 
		.do_sigpld_im(do_sigpld_im), 
		.do_sigpld_vld(do_sigpld_vld)
	);

	integer     dsep_preamble_out_re;
   integer     dsep_preamble_out_im;
   integer     dsep_sigpld_out_re;
   integer     dsep_sigpld_out_im;

/*	integer     in_data_re;			//Modified by baiyf
	integer     in_data_im;
	integer     frame_num=0;
	integer     read_cnt;*/
	
   reg  [11:0]  inputdata_re  [0:9535-1];
   reg  [11:0]  inputdata_im  [0:9535-1];
	 
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di_re = 0;
		di_im = 0;
		di_vld = 0;
		max_indx = 0;
		max_indx_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		dsep_preamble_out_re = $fopen("./debug_data/dsep_preamble_out_re.dat", "w");
      dsep_preamble_out_im = $fopen("./debug_data/dsep_preamble_out_im.dat", "w");
      dsep_sigpld_out_re = $fopen("./debug_data/dsep_sigpld_out_re.dat", "w");
      dsep_sigpld_out_im = $fopen("./debug_data/dsep_sigpld_out_im.dat", "w");
      $readmemb("./debug_data/ssync_output_re.dat", inputdata_re);			//Modified by baiyf
      $readmemb("./debug_data/ssync_output_im.dat", inputdata_im);
/*		in_data_re = $fopen("./debug_data/ssync_out_re.dat","r+b");			
		in_data_im = $fopen("./debug_data/ssync_out_im.dat","r+b");
		for(read_cnt=0;read_cnt<9536;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<9536;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end*/
      rst = 0;

    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 40000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 9535*3 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(dsep_preamble_out_re);
                $fclose(dsep_preamble_out_im);
                $fclose(dsep_sigpld_out_re);
                $fclose(dsep_sigpld_out_im);
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
            // input is valid every 3 clock cycle
            if (cnt >= VALUE1 && cnt < VALUE2) begin
                if (cnt%3 == 1) begin
                    indx <= indx + 1;
                end
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
            di_vld <= 0;
        end
        else begin
            // input is valid every 3 clock cycle
            if (cnt >= VALUE1 && cnt <= VALUE2  && cnt%3 == 1) begin
                di_vld <= 1;
            end
            else begin
                di_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            max_indx <= 0;
        end
        else begin
            // depends on the ssync module
            if (indx >= 1566) begin
                max_indx <= 10'd107;
            end
            else begin
                max_indx <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            max_indx_vld <= 0;
        end
        else begin
            // depends on the ssync module
            if (indx == 1701) begin
                max_indx_vld <= 1;
            end
            else begin
                max_indx_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (do_preamble_vld) begin
            $fdisplay(dsep_preamble_out_re, "%b", do_preamble_re);
            $fdisplay(dsep_preamble_out_im, "%b", do_preamble_im);
        end
        if (do_sigpld_vld) begin
            $fdisplay(dsep_sigpld_out_re, "%b", do_sigpld_re);
            $fdisplay(dsep_sigpld_out_im, "%b", do_sigpld_im);
        end
    end
	
/*	always begin														//Modified by baiyf
	    wait((cnt==MAX)&&(frame_num<`NF-1)) begin
		     rst=1;
			  #1000 for(read_cnt=0;read_cnt<9536;read_cnt=read_cnt+1) begin
			      $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
			  end
			  for(read_cnt=0;read_cnt<9536;read_cnt=read_cnt+1) begin
			      $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
			  end
			  rst=0;
			  frame_num=frame_num+1;
	    end
	end
*/	
endmodule