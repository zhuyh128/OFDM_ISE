`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:53:03 12/13/2016
// Design Name:   SCD
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_scd.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SCD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_scd;

	// Inputs
	reg clk;
	reg rst;
	reg di;
	reg di_vld;

	// Outputs
	wire do;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	SCD uut (
		.clk(clk), 
		.rst(rst), 
		.di(di), 
		.di_vld(di_vld), 
		.do(do), 
		.do_vld(do_vld)
	);

    integer scd_ouput;
    reg inputdata [0:95];

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di = 0;
		di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
     scd_ouput = $fopen("./debug_data/scd_output.dat","w");
     $readmemb("./debug_data/sdmod_output.dat",inputdata);

        rst = 0;
    end

    localparam MAX = 400;
    integer cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(scd_ouput);
                $stop;
            end
            if (cnt < MAX) begin
                cnt <= cnt + 1;
            end
        end
    end

    reg [6:0] indx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            indx <= 0;        
        end
        else begin
            if ((cnt > 10) && (indx < 95)) begin
                indx <= indx + 1;
            end
            if (indx == 95) begin
                indx <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            di <= 0;
            di_vld <= 0;
        end
        else begin
            di <= inputdata[indx];

            if ((cnt > 10) && (cnt < 107)) begin
                di_vld <= 1;
            end
            else begin
                di_vld <= 0;
            end
        end
    end

    // ----------------------------------------------------------------------
    always #5 clk = ~clk;

    // save data into file
    always @(posedge clk or posedge rst) begin
        if (do_vld) begin
            $fdisplay(scd_ouput,"%b",do);
        end
    end


endmodule


