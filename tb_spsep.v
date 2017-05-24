`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:31:02 12/13/2016
// Design Name:   SPSEP
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_spsep.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPSEP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_spsep;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] din_re;
	reg [11:0] din_im;
	reg din_vld;

	// Outputs
	wire [11:0] dout_signal_re;
	wire [11:0] dout_signal_im;
	wire dout_signal_vld;
	wire [11:0] dout_payload_re;
	wire [11:0] dout_payload_im;
	wire dout_payload_vld;

	// Instantiate the Unit Under Test (UUT)
	SPSEP uut (
		.clk(clk), 
		.rst(rst), 
		.din_re(din_re), 
		.din_im(din_im), 
		.din_vld(din_vld), 
		.dout_signal_re(dout_signal_re), 
		.dout_signal_im(dout_signal_im), 
		.dout_signal_vld(dout_signal_vld), 
		.dout_payload_re(dout_payload_re), 
		.dout_payload_im(dout_payload_im), 
		.dout_payload_vld(dout_payload_vld)
	);

	integer     spsep_output_sig_re;
   integer     spsep_output_sig_im;
   integer     spsep_output_pld_re;
   integer     spsep_output_pld_im;

   reg  [11:0] inputdata_re  [0:3584-1];
   reg  [11:0] inputdata_im  [0:3584-1];
	 
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		din_re = 0;
		din_im = 0;
		din_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		spsep_output_sig_re = $fopen("./debug_data/spsep_output_sig_re.dat", "w");
      spsep_output_sig_im = $fopen("./debug_data/spsep_output_sig_im.dat", "w");
      spsep_output_pld_re = $fopen("./debug_data/spsep_output_pld_re.dat", "w");
      spsep_output_pld_im = $fopen("./debug_data/spsep_output_pld_im.dat", "w");
      $readmemb("./debug_data/ccom_output_re.dat", inputdata_re);
      $readmemb("./debug_data/ccom_output_im.dat", inputdata_im);
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
                $fclose(spsep_output_sig_re);
                $fclose(spsep_output_sig_im);
                $fclose(spsep_output_pld_re);
                $fclose(spsep_output_pld_im);
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
            din_re <= 0;
            din_im <= 0;
        end
        else begin
            din_re <= inputdata_re[indx];
            din_im <= inputdata_im[indx];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            din_vld <= 0;
        end
        else begin
            if (cnt >= VALUE1 && cnt <= VALUE2) begin
                din_vld <= 1;
            end
            else begin
                din_vld <= 0;
            end
        end
    end

    //--------------
    // output

    always @(posedge clk or posedge rst) begin
        if (dout_signal_vld) begin
            $fdisplay(spsep_output_sig_re, "%b", dout_signal_re);
            $fdisplay(spsep_output_sig_im, "%b", dout_signal_im);
        end
        if (dout_payload_vld) begin
            $fdisplay(spsep_output_pld_re, "%b", dout_payload_re);
            $fdisplay(spsep_output_pld_im, "%b", dout_payload_im);
        end
    end

endmodule

