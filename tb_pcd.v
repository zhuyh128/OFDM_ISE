`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:04:57 12/13/2016
// Design Name:   PCD
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_pcd.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PCD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_pcd;

	// Inputs
	reg reset;
	reg clk_in;
	reg [7:0] symbol_din;
	reg frame_start;

	// Outputs
	wire [0:0] ldpc_dout;
	wire frame_finish;

	// Instantiate the Unit Under Test (UUT)
	PCD uut (
		.reset(reset), 
		.clk_in(clk_in), 
		.symbol_din(symbol_din), 
		.frame_start(frame_start), 
		.ldpc_dout(ldpc_dout), 
		.frame_finish(frame_finish)
	);

    integer pcd_output;
    reg [7:0] inputdata [0:8639];

    reg [13:0] addr_dec_in;
    reg out_dec;

	initial begin
		// Initialize Inputs
		reset = 1;
		clk_in = 0;
		symbol_din = 0;
		frame_start = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		pcd_output = $fopen("./debug_data/pcd_output.dat","w");
      $readmemb("./debug_data/pdmod_output.dat",inputdata);
      // frame_start = 1;
        reset = 0;
        #15;
        frame_start = 1;
        #86400;
        frame_start = 0;
    end

    always #5 clk_in = ~clk_in;

    localparam MAX = 450000;
    integer cnt;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(pcd_output);
                $stop;
            end
            if (cnt < MAX) begin
                cnt <= cnt+ 1;
            end
        end
    end

    reg [13:0] indx_in;
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            // reset
            indx_in <= 0;
        end
        else begin
            if (cnt > 0 && indx_in < 8640) begin
                indx_in <= indx_in + 1;
            end
            if (indx_in == 8640) begin
                indx_in <= 0;
            end
        end
    end

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            // reset
            symbol_din <= 0;
        end
        else begin
            if (cnt > 0 && cnt < 8641) begin
                symbol_din <= inputdata[indx_in];
            end
            else begin
                symbol_din <= 0;  
            end
        end
    end
    
    always @(frame_finish or posedge clk_in) begin
        if (reset) begin
            // reset
            out_dec <= 0;
        end
        else begin
            if (frame_finish) begin
                out_dec <= 1;
            end
            if (addr_dec_in == 4319) begin
                out_dec <= 0;
            end
        end
    end


    // -----------------------------------------------------------
    always @(posedge clk_in) begin
        if (out_dec) begin
            if (addr_dec_in != 4319) begin
                addr_dec_in <= addr_dec_in + 1;
                $fdisplay(pcd_output,"%b",ldpc_dout);
            end
        end
        else begin
            addr_dec_in <= 14'h3fff;
        end
    end

endmodule