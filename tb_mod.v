`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:13:29 12/12/2016
// Design Name:   MOD
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_mod.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MOD
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_mod;

	// Inputs
	reg signal_clk;
	reg signal_rst;
	reg signal_di;
	reg signal_di_vld;
	reg payload_clk;
	reg payload_rst;
	reg payload_di;
	reg payload_di_vld;

	// Outputs
	wire [11:0] signal_do_re;
	wire [11:0] signal_do_im;
	wire signal_do_vld;
	wire [11:0] payload_do_re;
	wire [11:0] payload_do_im;
	wire payload_do_sym_end;
	wire payload_do_vld;
	

	// Instantiate the Unit Under Test (UUT)
	MOD uut (
		.signal_clk(signal_clk), 
		.signal_rst(signal_rst), 
		.signal_di(signal_di), 
		.signal_di_vld(signal_di_vld), 
		.signal_do_re(signal_do_re), 
		.signal_do_im(signal_do_im), 
		.signal_do_vld(signal_do_vld), 
		.payload_clk(payload_clk), 
		.payload_rst(payload_rst), 
		.payload_di(payload_di), 
		.payload_di_vld(payload_di_vld), 
		.payload_do_re(payload_do_re), 
		.payload_do_im(payload_do_im), 
		.payload_do_sym_end(payload_do_sym_end), 
		.payload_do_vld(payload_do_vld)
	);
	integer  mod_signal_out_re;
   integer  mod_signal_out_im;
   integer  mod_payload_out_re;
   integer  mod_payload_out_im;

	integer  in_data_sig;						//Modified by baiyf
	integer  in_data_pld;
	integer  read_cnt;
	integer  frame_num=0;

   reg     signal_input  [0:960-1];
   reg     payload_input [0:9600-1];
	
	initial begin
		// Initialize Inputs
		signal_clk = 0;
		signal_rst = 1;
		signal_di = 0;
		signal_di_vld = 0;
		payload_clk = 0;
		payload_rst = 1;
		payload_di = 0;
		payload_di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		mod_signal_out_re = $fopen("./debug_data/mod_signal_out_re.dat");
      mod_signal_out_im = $fopen("./debug_data/mod_signal_out_im.dat");
      mod_payload_out_re = $fopen("./debug_data/mod_payload_out_re.dat");
      mod_payload_out_im = $fopen("./debug_data/mod_payload_out_im.dat");
		
		in_data_sig=$fopen("./debug_data/cenc_sig_output.dat","r+b");			//Modified by baiyf
		in_data_pld=$fopen("./debug_data/cenc_pld_output.dat","r+b");
		
		for(read_cnt=0;read_cnt<960;read_cnt=read_cnt+1)
		begin
		    $fscanf(in_data_sig,"%b",signal_input[read_cnt]);
		end
		for(read_cnt=0;read_cnt<9600;read_cnt=read_cnt+1)
		begin
		    $fscanf(in_data_pld,"%b",payload_input[read_cnt]);
		end
		
//      $readmemb("./debug_data/cenc_sig_output.dat", signal_input);
//      $readmemb("./debug_data/cenc_pld_output.dat", payload_input);

      #(`CLK_PERIOD*2);
      signal_rst = 0;
      payload_rst = 0;
    end


    //--------------------------------------------------------------------------
    // for signal segment
    always #(`CLK_PERIOD/2) signal_clk  = ~signal_clk;

    integer     cnt1;

    localparam  MAX1 = 2000,
                VALUE1 = 5,
                VALUE2 = VALUE1 + 960 - 1; // length of [value1, value2] = 960

    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            cnt1 <= 0;
        end
        else begin
            if (cnt1 < MAX1)    
                cnt1 <= cnt1 + 1;
            if ((cnt1 == MAX1)&&(cnt2==MAX3)) begin
                $fclose(mod_signal_out_re);
                $fclose(mod_signal_out_im);
            end
        end
    end

    reg  [9:0]  indx1;
    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            indx1 <= 0;
        end
        else begin
            if (cnt1 >= VALUE1 && cnt1 <= VALUE2) begin
                indx1 <= indx1 + 1;
            end
            else begin
                indx1 <= 0;
            end
        end
    end

    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            signal_di <= 0;
        end
        else begin
            signal_di <= signal_input[indx1];
        end
    end

    always @(posedge signal_clk or posedge signal_rst) begin
        if (signal_rst) begin
            // reset
            signal_di_vld <= 0;
        end
        else begin
            if (cnt1 >= VALUE1 && cnt1 <= VALUE2) begin
                signal_di_vld <= 1;
            end
            else begin
                signal_di_vld <= 0;
            end
        end
    end

    always @(posedge signal_clk) begin
        if (signal_do_vld) begin
            $fdisplay(mod_signal_out_re, "%b", signal_do_re);
            $fdisplay(mod_signal_out_im, "%b", signal_do_im);
        end
    end

    //--------------------------------------------------------------------------
    // for payload segment

    always #(`CLK_PERIOD/2) payload_clk = ~payload_clk;

    integer     cnt2;

    localparam  MAX3 = 10000,
                VALUE3 = 5,
                VALUE4 = VALUE1 + 9600 - 1; // length of [value1, value2] = 960

    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            cnt2 <= 0;
        end
        else begin
            if (cnt2 < MAX3)					
                cnt2 <= cnt2 + 1;
            if ((cnt2 == MAX3)&&(cnt1==MAX1)) begin
                $fclose(mod_payload_out_re);
                $fclose(mod_payload_out_im);
                $stop;
            end
        end
    end

    reg  [14:0]  indx2;
    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            indx2 <= 0;
        end
        else begin
            if (cnt2 >= VALUE3 && cnt2 <= VALUE4) begin
                indx2 <= indx2 + 1;
            end
            else begin
                indx2 <= 0;
            end
        end
    end

    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_di <= 0;
        end
        else begin
            payload_di <= payload_input[indx2];
        end
    end

    always @(posedge payload_clk or posedge payload_rst) begin
        if (payload_rst) begin
            // reset
            payload_di_vld <= 0;
        end
        else begin
            if (cnt2 >= VALUE3 && cnt2 <= VALUE4) begin
                payload_di_vld <= 1;
            end
            else begin
                payload_di_vld <= 0;
            end
        end
    end

    always @(posedge payload_clk) begin
        if (payload_do_vld) begin
            $fdisplay(mod_payload_out_re, "%b", payload_do_re);
            $fdisplay(mod_payload_out_im, "%b", payload_do_im);
        end
    end
/*	 
	 always 																//Modified by baiyf
	 begin
	 wait((cnt1==MAX1)&&(cnt2==MAX3)&&(frame_num<2))
		begin
			signal_rst=1;
			payload_rst=1;
			
			#1000 for(read_cnt=0;read_cnt<960;read_cnt=read_cnt+1) begin
		       $fscanf(in_data_sig,"%b",signal_input[read_cnt]);
			end
			
			for(read_cnt=0;read_cnt<9600;read_cnt=read_cnt+1)begin
		       $fscanf(in_data_pld,"%b",payload_input[read_cnt]);
			end
			signal_rst=0;
			payload_rst=0;
			frame_num=frame_num+1;
			
		end
	 end
*/
endmodule