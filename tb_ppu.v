`timescale 1ns / 1ps
`include "global_define.vh"      //% include global define file

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:35:55 12/19/2016
// Design Name:   PPU
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_ppu.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_ppu;

	// Inputs
	reg clk;
	reg rst;
	reg di;
	reg di_vld;

	// Outputs
	wire do;
	wire do_vld;
	wire [3:0] do_sym_num;

	// Instantiate the Unit Under Test (UUT)
	PPU uut (
		.clk(clk), 
		.rst(rst), 
		.di(di), 
		.di_vld(di_vld), 
		.do(do), 
		.do_vld(do_vld), 
		.do_sym_num(do_sym_num)
	);
	integer  ppu_output;
   reg  inputdata  [0:8640-1];
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		ppu_output = $fopen("./debug_data/ppu_output.dat", "w");
      $readmemb("./debug_data/fpce_output.dat", inputdata);
      rst = 0;
    end

    //--------------------------------------------------------------------------
    
    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 8640 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(ppu_output);
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
            di <= 0;
        end
        else begin
            di <= inputdata[indx];
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

    // sava output
    always @(posedge clk) begin
        if (do_vld) begin
            $fdisplay(ppu_output, "%b", do);
        end
    end
endmodule