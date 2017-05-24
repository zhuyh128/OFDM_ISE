`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:39:17 12/13/2016
// Design Name:   PDMOD
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_pdmod.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PDMOD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_pdmod;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;
	reg [11:0] di_sigma2;
	reg di_sigma2_vld;

	// Outputs
	wire [7:0] do_llr;
	wire do_llr_vld;

	// Instantiate the Unit Under Test (UUT)
	PDMOD uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.di_sigma2(di_sigma2), 
		.di_sigma2_vld(di_sigma2_vld), 
		.do_llr(do_llr), 
		.do_llr_vld(do_llr_vld)
	);

	reg  [11:0]  inputdata_re      [0:3072-1];
   reg  [11:0]  inputdata_im      [0:3072-1];
   reg  [11:0]  inputdata_sigma2  [0:512-1];
   integer      pdmod_output;

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		pdmod_output = $fopen("./debug_data/pdmod_output.dat", "w");
      $readmemb("./debug_data/spsep_output_pld_re.dat", inputdata_re);
      $readmemb("./debug_data/spsep_output_pld_im.dat", inputdata_im);
      $readmemb("./debug_data/cest_output_N.dat", inputdata_sigma2);
      rst = 0;
    end

//--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 40000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 3072 - 1,
                 VALUE3 = 10,
                 VALUE4 = VALUE3 + 512 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(pdmod_output);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    // payload index
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

    // noise index
    integer  noise_idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            noise_idx <= 0;
        end
        else begin
            if (cnt >= VALUE3 && cnt < VALUE4) begin
                noise_idx <= noise_idx + 1;
            end
            else begin
                noise_idx <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            di_sigma2 <= 0;
        end
        else begin
            di_sigma2 <= inputdata_sigma2[noise_idx];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            di_sigma2_vld <= 0;
        end
        else begin
            if (cnt >= VALUE3 && cnt <= VALUE4) begin
                di_sigma2_vld <= 1;
            end
            else begin
                di_sigma2_vld <= 0;
            end
        end
    end

    //---------------------
    // save the output

    always @(posedge clk or posedge rst) begin
        if (do_llr_vld) begin
            $fdisplay(pdmod_output, "%b", do_llr);
        end
    end

endmodule