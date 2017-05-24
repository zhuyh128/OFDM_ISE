`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:39:09 12/09/2016
// Design Name:   TRANS
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_trans.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TRANS
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_trans;

	// Inputs
	reg new_frame;
	reg sig_clk_g;
	reg sig_clk_c;
	reg sig_rst;
	reg [15:0] sig_di_len;
	reg [3:0] sig_di_type;
	reg sig_di_vld;
	reg pld_clk;
	reg pld_rst;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;
	
	// Instantiate the Unit Under Test (UUT)
	TRANS uut (
		.new_frame(new_frame), 
		.sig_clk_g(sig_clk_g), 
		.sig_clk_c(sig_clk_c), 
		.sig_rst(sig_rst), 
		.sig_di_len(sig_di_len), 
		.sig_di_type(sig_di_type), 
		.sig_di_vld(sig_di_vld), 
		.pld_clk(pld_clk), 
		.pld_rst(pld_rst), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);

	integer  trans_output_re;
   integer  trans_output_im;
	
	reg  signal_bits  [0:31];
	
//	integer frame_num=0;			//Modified by baiyf
	
	initial begin
		// Initialize Inputs
		new_frame = 0;
		sig_clk_g = 0;
		sig_clk_c = 0;
		sig_rst = 1;
		sig_di_len = 0;
		sig_di_type = 0;
		sig_di_vld = 0;
		pld_clk = 0;
		pld_rst = 1;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
	trans_output_re = $fopen("./debug_data/trans_output_re.dat", "w");
   trans_output_im = $fopen("./debug_data/trans_output_im.dat", "w");
   $readmemb("./debug_data/signal.dat", signal_bits);
   sig_rst = 0;
   pld_rst = 0;
   end

    //--------------------------------------------------------------------------

   always #(`CLK_PERIOD/2)    sig_clk_c = ~sig_clk_c;
   always #(`CLK_PERIOD/2*3)  sig_clk_g = ~sig_clk_g;
   always #(`CLK_PERIOD/2)    pld_clk   = ~pld_clk;
   integer  cnt = 0;
   localparam   MAX = 10000,
                VALUE1 = 20,
                VALUE2 = VALUE1 + 1;

   always @(posedge sig_clk_g) begin
       if (sig_rst) begin
           cnt <= 0;
       end
       else begin
           if (cnt == MAX) begin
               $fclose(trans_output_re);
               $fclose(trans_output_im);
               $stop;
           end
           else begin
               cnt <= cnt + 1;
           end
       end
   end

   always @(posedge sig_clk_g) begin
        if (sig_rst) begin
            // reset
            sig_di_len <= 0;
            sig_di_type <= 0;
            sig_di_vld <= 0;
        end
        else begin
            if (cnt == VALUE1) begin
                sig_di_type[0] <= signal_bits[8];
                sig_di_type[1] <= signal_bits[9];
                sig_di_type[2] <= signal_bits[10];
                sig_di_type[3] <= signal_bits[11];
                sig_di_len[0]  <= signal_bits[12];
                sig_di_len[1]  <= signal_bits[13];
                sig_di_len[2]  <= signal_bits[14];
                sig_di_len[3]  <= signal_bits[15];
                sig_di_len[4]  <= signal_bits[16];
                sig_di_len[5]  <= signal_bits[17];
                sig_di_len[6]  <= signal_bits[18];
                sig_di_len[7]  <= signal_bits[19];
                sig_di_len[8]  <= signal_bits[20];
                sig_di_len[9]  <= signal_bits[21];
                sig_di_len[10] <= signal_bits[22];
                sig_di_len[11] <= signal_bits[23];
                sig_di_len[12] <= signal_bits[24];
                sig_di_len[13] <= signal_bits[25];
                sig_di_len[14] <= signal_bits[26];
                sig_di_len[15] <= signal_bits[27];
            end
            if (cnt == VALUE1) begin
                new_frame <= 1;
            end
            else begin
                new_frame <= 0;
            end
            if (cnt == VALUE2) begin
                sig_di_vld <= 1;
            end
            else begin
                sig_di_vld <= 0;
            end
        end
    end

   //-----------------------
   // save result
   always @(posedge pld_clk) begin
       if (do_vld) begin
           $fdisplay(trans_output_re, "%b", do_re);
           $fdisplay(trans_output_im, "%b", do_im);
       end
   end

/*	always						//Modified by baiyf
	begin
		wait((cnt==MAX)&&(frame_num<`NF-1))
		begin
			sig_rst=1;
			pld_rst=1;
			
			#100 sig_rst=0;
			pld_rst=0;
			frame_num=frame_num+1;
		end
	end
*/
endmodule
