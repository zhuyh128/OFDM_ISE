`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:02:34 03/09/2017
// Design Name:   OPG
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_opg.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: OPG
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_opg;

	// Inputs
	reg clk;
	reg rst;
	reg rd_en;

	// Outputs
	wire do;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	OPG uut (
		.clk(clk), 
		.rst(rst), 
		.rd_en(rd_en), 
		.do(do), 
		.do_vld(do_vld)
	);
	
	integer opg_output;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		rd_en = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		opg_output = $fopen("./debug_data/opg_output.dat","w");

        #(`CLK_PERIOD*2);
        rst = 0;
        #50;
        rd_en = 1;
        #`CLK_PERIOD;
        rd_en = 0;
    end

    // -------------------------------------------------------------------

    always #(`CLK_PERIOD/2) clk = ~clk;

    localparam MAX = 5000;
    integer cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(opg_output);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (do_vld) begin
            $fdisplay(opg_output, "%b", do);
        end
    end
	 
endmodule

