`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:18:33 10/19/2016
// Design Name:   TOP
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_top.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TOP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_top;

	// Inputs
	reg clk_in_p;
	reg clk_in_n;
	reg rst_In;

	// Outputs
	wire do_signal;
	wire do_signal_vld;
	wire do_payload;
	wire do_payload_vld;
   // wire debug_clk;


	// Instantiate the Unit Under Test (UUT)
	TOP uut (
		.clk_in_p(clk_in_p), 
		.clk_in_n(clk_in_n), 
		.rst_In(rst_In), 

		.do_signal(do_signal), 
		.do_signal_vld(do_signal_vld), 
		.do_payload(do_payload), 
		.do_payload_vld(do_payload_vld)
	//	.debug_clk(debug_clk)
	);

	// integer top_s_output;
	// integer top_p_output;

	integer  top_signal_output;
   integer  top_payload_output;

	initial begin
		// Initialize Inputs
		clk_in_p = 0;
		clk_in_n = 1;
		rst_In = 1;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		top_signal_output = $fopen("./debug_data/top_signal_output.dat","w");
      top_payload_output = $fopen("./debug_data/top_payload_output.dat", "w");
      rst_In = 0;


      #(`CLK_PERIOD*3*100);
      rst_In = 1;
      #(`CLK_PERIOD*5);
      rst_In = 0;
	end

	always #(`CLK_PERIOD/2) clk_in_p = ~clk_in_p;
	always #(`CLK_PERIOD/2) clk_in_n = ~clk_in_n;

	integer  cnt = 0;
   localparam   MAX = 240000000,
                 VALUE1 = 1200;

    always @(posedge clk_in_p or negedge clk_in_n or posedge rst_In) begin
        if (rst_In) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(top_payload_output);
                $fclose(top_signal_output);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

/*
    always @(posedge clk_In or posedge rst_In) begin
        if (rst_In) begin
            // reset
            start_butten <= 0;
        end
        else begin
            if (cnt == VALUE1) begin
                start_butten <= 1;
            end
            else begin
                start_butten <= 0;
            end
        end
    end
*/


    //----------------------------------------
    // save output
    always @(posedge clk_in_p or negedge clk_in_n or posedge rst_In) begin     //debug_clk
        if (do_payload_vld) begin
           $fdisplay(top_payload_output, "%b", do_payload);
        end
////////////////////////////////////////////////////////////////////////////////
        if (do_signal_vld) begin
           $fdisplay(top_signal_output, "%b", do_signal);
        end
////////////////////////////////////////////////////////////////////////////////
    end

endmodule
