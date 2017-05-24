`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:35:32 12/13/2016
// Design Name:   SDMOD
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_sdmod.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SDMOD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_sdmod;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_vld;

	// Outputs
	wire do;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	SDMOD uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_vld(di_vld), 
		.do(do), 
		.do_vld(do_vld)
	);
	
	integer  sdmod_output;
   reg  [13:0]  inputdata_re  [0:512-1];
   reg  [13:0]  inputdata_im  [0:512-1];

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
		sdmod_output = $fopen("./debug_data/sdmod_output.dat", "w");
        $readmemb("./debug_data/spsep_output_sig_re.dat", inputdata_re);
        $readmemb("./debug_data/spsep_output_sig_im.dat", inputdata_im);
        rst = 0;
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 5000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 512 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(sdmod_output);
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

    //---------------------
    // save the output

    always @(posedge clk or posedge rst) begin
        if (do_vld) begin
            $fdisplay(sdmod_output, "%b", do);
        end
    end

endmodule