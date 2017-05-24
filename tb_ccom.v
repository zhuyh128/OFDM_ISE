`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:21:44 12/13/2016
// Design Name:   CCOM
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_ccom.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CCOM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_ccom;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] din_sp_re;
	reg [11:0] din_sp_im;
	reg din_sp_vld;
	reg [11:0] din_H_re;
	reg [11:0] din_H_im;
	reg din_H_vld;

	// Outputs
	wire [11:0] dout_re;
	wire [11:0] dout_im;
	wire dout_vld;

	// Instantiate the Unit Under Test (UUT)
	CCOM uut (
		.clk(clk), 
		.rst(rst), 
		.din_sp_re(din_sp_re), 
		.din_sp_im(din_sp_im), 
		.din_sp_vld(din_sp_vld), 
		.din_H_re(din_H_re), 
		.din_H_im(din_H_im), 
		.din_H_vld(din_H_vld), 
		.dout_re(dout_re), 
		.dout_im(dout_im), 
		.dout_vld(dout_vld)
	);
	
	integer      ccom_output_re;
   integer      ccom_output_im;

   reg  [13:0]  inputdata_sp_re  [0:3584-1];
   reg  [13:0]  inputdata_sp_im  [0:3584-1];
   reg  [11:0]  inputdata_H_re   [0:512-1];
   reg  [11:0]  inputdata_H_im   [0:512-1];

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		din_sp_re = 0;
		din_sp_im = 0;
		din_sp_vld = 0;
		din_H_re = 0;
		din_H_im = 0;
		din_H_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		ccom_output_re = $fopen("./debug_data/ccom_output_re.dat", "w");
      ccom_output_im = $fopen("./debug_data/ccom_output_im.dat", "w");
      $readmemb("./debug_data/spfft_output_re.dat", inputdata_sp_re);
      $readmemb("./debug_data/spfft_output_im.dat", inputdata_sp_im);
      $readmemb("./debug_data/cest_output_H_re.dat", inputdata_H_re);
      $readmemb("./debug_data/cest_output_H_im.dat", inputdata_H_im);
      rst = 0;
    end

    //--------------------------------------------------------------------------
    //

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 3584 - 1,
                 VALUE3 = VALUE2 + 10,
                 VALUE4 = VALUE3 + 512 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(ccom_output_re);
                $fclose(ccom_output_im);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    integer  indx1;
    always @(posedge clk) begin
        if (rst) begin
            indx1 <= 0;
        end
        else begin
            if (cnt >= VALUE1 && cnt < VALUE2) begin
                indx1 <= indx1 + 1;
            end
            else begin
                indx1 <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_sp_re <= 0;
            din_sp_im <= 0;
        end
        else begin
            din_sp_re <= inputdata_sp_re[indx1];
            din_sp_im <= inputdata_sp_im[indx1];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_sp_vld <= 0;
        end
        else begin
            if (cnt >= VALUE1 && cnt <= VALUE2) begin
                din_sp_vld <= 1;
            end
            else begin
                din_sp_vld <= 0;
            end
        end
    end

    //----------------------------------------
    
    integer  indx2;
    always @(posedge clk) begin
        if (rst) begin
            indx2 <= 0;
        end
        else begin
            if (cnt >= VALUE3 && cnt < VALUE4) begin
                indx2 <= indx2 + 1;
            end
            else begin
                indx2 <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_H_re <= 0;
            din_H_im <= 0;
        end
        else begin
            din_H_re <= inputdata_H_re[indx2];
            din_H_im <= inputdata_H_im[indx2];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_H_vld <= 0;
        end
        else begin
            if (cnt >= VALUE3 && cnt <= VALUE4) begin
                din_H_vld <= 1;
            end
            else begin
                din_H_vld <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (dout_vld) begin
            $fdisplay(ccom_output_re, "%b", dout_re);
            $fdisplay(ccom_output_im, "%b", dout_im);
        end
    end

endmodule
