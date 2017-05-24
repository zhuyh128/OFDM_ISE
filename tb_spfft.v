`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:16:04 12/13/2016
// Design Name:   SPFFT
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_spfft.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPFFT
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_spfft;

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

	// Instantiate the Unit Under Test (UUT)
	SPFFT uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);
	
	integer     spfft_output_re;
   integer     spfft_output_im;

   reg  [11:0]  inputdata_re  [0:3584-1];  /// 512*7 = 3584
   reg  [11:0]  inputdata_im  [0:3584-1];

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
		spfft_output_re = $fopen("./debug_data/spfft_output_re.dat", "w");
      spfft_output_im = $fopen("./debug_data/spfft_output_im.dat", "w");
      $readmemb("./debug_data/decp_output_re.dat", inputdata_re);
      $readmemb("./debug_data/decp_output_im.dat", inputdata_im);
      rst = 0;

    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 3584 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(spfft_output_re);
                $fclose(spfft_output_im);
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
        if (do_vld) begin
            $fdisplay(spfft_output_re, "%b", do_re);
            $fdisplay(spfft_output_im, "%b", do_im);
        end
    end

endmodule
