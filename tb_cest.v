`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:58:36 12/13/2016
// Design Name:   CEST
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_cest.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CEST
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_cest;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;

	// Outputs
	wire [11:0] H_estimated_re;
	wire [11:0] H_estimated_im;
	wire H_estimated_vld;
	wire [11:0] sigma2;
	wire sigma2_vld;

	// Instantiate the Unit Under Test (UUT)
	CEST uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.H_estimated_re(H_estimated_re), 
		.H_estimated_im(H_estimated_im), 
		.H_estimated_vld(H_estimated_vld), 
		.sigma2(sigma2), 
		.sigma2_vld(sigma2_vld)
	);

	integer      cest_output_H_re;
   integer      cest_output_H_im;
   integer      cest_output_N;
   reg  [11:0]  inputdata_re  [0:3072-1];  // 512*6 = 3072
   reg  [11:0]  inputdata_im  [0:3072-1];
	 
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
		cest_output_H_re = $fopen("./debug_data/cest_output_H_re.dat", "w");
      cest_output_H_im = $fopen("./debug_data/cest_output_H_im.dat", "w");
      cest_output_N = $fopen("./debug_data/cest_output_N.dat", "w");
      $readmemb("./debug_data/dsep_preamble_out_re.dat", inputdata_re);
      $readmemb("./debug_data/dsep_preamble_out_im.dat", inputdata_im);
      rst = 0;
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 3072 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(cest_output_H_re);
                $fclose(cest_output_H_im);
                $fclose(cest_output_N);
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
            di_vld <= 0;
        end
        else begin
            if (cnt >= VALUE1 && cnt <= VALUE2) begin
                di_vld <= 1;
            end
            else begin
                di_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (H_estimated_vld) begin
            $fdisplay(cest_output_H_re, "%b", H_estimated_re);
            $fdisplay(cest_output_H_im, "%b", H_estimated_im);
        end
    end

    always @(posedge clk or posedge rst) begin
        if (sigma2_vld) begin
            $fdisplay(cest_output_N, "%b", sigma2);
        end
    end

endmodule
