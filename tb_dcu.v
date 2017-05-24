`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:21:42 12/12/2016
// Design Name:   DCU
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_dcu.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: DCU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_dcu;

	// Inputs
	reg new_frame;
	reg signal_clk;
	reg [11:0] signal_di_re;
	reg [11:0] signal_di_im;
	reg signal_di_vld;
	reg payload_clk;
	reg [11:0] payload_di_re;
	reg [11:0] payload_di_im;
	reg [3:0] payload_di_num;
	reg payload_di_sym_end;
	reg payload_di_vld;
	reg clk_o;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_last;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	DCU uut (
		.new_frame(new_frame), 
		.signal_clk(signal_clk), 
		.signal_di_re(signal_di_re), 
		.signal_di_im(signal_di_im), 
		.signal_di_vld(signal_di_vld), 
		.payload_clk(payload_clk), 
		.payload_di_re(payload_di_re), 
		.payload_di_im(payload_di_im), 
		.payload_di_num(payload_di_num), 
		.payload_di_sym_end(payload_di_sym_end), 
		.payload_di_vld(payload_di_vld), 
		.clk_o(clk_o), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_last(do_last), 
		.do_vld(do_vld)
	);
	
    integer              dcu_output_re;
    integer              dcu_output_im;
	 
/*	 integer 				 frame_num=0;						//Modified by baiyf
	 integer 				 in_sig_r;
	 integer					 in_sig_i;
	 integer					 in_pld_r;
	 integer					 in_pld_i;
	 integer					 read_cnt;
*/
    reg signed  [11:0]   signal_input_re   [0:480-1];
    reg signed  [11:0]   signal_input_im   [0:480-1];
    reg signed  [11:0]   payload_input_re  [0:2400-1];
    reg signed  [11:0]   payload_input_im  [0:2400-1];

	initial begin
		// Initialize Inputs
		new_frame = 1;
		signal_clk = 0;
		signal_di_re = 0;
		signal_di_im = 0;
		signal_di_vld = 0;
		
		payload_clk = 0;
		payload_di_re = 0;
		payload_di_im = 0;
		payload_di_num = 5;
		payload_di_sym_end = 0;
		payload_di_vld = 0;
		clk_o = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		dcu_output_re = $fopen("./debug_data/dcu_output_re.dat");
      dcu_output_im = $fopen("./debug_data/dcu_output_im.dat");
      $readmemb("./debug_data/mod_signal_out_re.dat", signal_input_re);
      $readmemb("./debug_data/mod_signal_out_im.dat", signal_input_im);
      $readmemb("./debug_data/mod_payload_out_re.dat", payload_input_re);
      $readmemb("./debug_data/mod_payload_out_im.dat", payload_input_im);
/*		in_sig_r=$fopen("./debug_data/mod_signal_out_re.dat","r+b");
		in_sig_i=$fopen("./debug_data/mod_signal_out_im.dat","r+b");
		in_pld_r=$fopen("./debug_data/mod_payload_out_re.dat","r+b");
		in_pld_i=$fopen("./debug_data/mod_payload_out_im.dat","r+b");
		
		for(read_cnt=0;read_cnt<480;read_cnt=read_cnt+1) begin			//Modified by baiyf
		    $fscanf(in_sig_r,"%b",signal_input_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<480;read_cnt=read_cnt+1) begin
		    $fscanf(in_sig_i,"%b",signal_input_im[read_cnt]);
		end
		for(read_cnt=0;read_cnt<2400;read_cnt=read_cnt+1) begin
		    $fscanf(in_pld_r,"%b",payload_input_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<2400;read_cnt=read_cnt+1) begin
		    $fscanf(in_pld_i,"%b",payload_input_im[read_cnt]);
		end
*/		
      new_frame = 0;

    end

    //--------------------------------------------------------------------------
    // for signal

    always #(`CLK_PERIOD/2) signal_clk = ~signal_clk;

    integer  cnt1;		

    localparam   MAX1 = 2000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 480*2 - 1;

    always @(posedge signal_clk) begin
        if (new_frame) begin
            cnt1 <= 0;
        end
        else begin
            if (cnt1 < MAX1) begin
                cnt1 <= cnt1 + 1;
            end
        end
    end

    integer  indx1;
    always @(posedge signal_clk) begin
        if (new_frame) begin
            indx1 <= 0;
        end
        else begin
            if (cnt1 >= VALUE1 && cnt1 <= VALUE2) begin
                if (cnt1%2) begin
                    indx1 <= indx1 + 1;
                end
            end
            else begin
                indx1 <= 0;
            end
        end
    end

    always @(posedge signal_clk) begin
        if (new_frame) begin
            signal_di_re <= 0;
            signal_di_im <= 0;
        end
        else begin
            signal_di_re <= signal_input_re[indx1];
            signal_di_im <= signal_input_im[indx1];
        end
    end

    always @(posedge signal_clk) begin
        if (new_frame) begin
            signal_di_vld <= 0;
        end
        else begin
            if (cnt1 >= VALUE1 && cnt1 <= VALUE2) begin
                if (cnt1%2) begin
                    signal_di_vld <= 1;
                end
                else begin
                    signal_di_vld <= 0;
                end
            end
            else begin
                signal_di_vld <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // for payload

    always #(`CLK_PERIOD/2) payload_clk = ~payload_clk;

    integer  cnt2;			

    localparam   MAX2 = 2400*4*2 + 200,
                 VALUE3 = 5,
                 VALUE4 = VALUE1 + 2400*4 - 1;

    always @(posedge payload_clk) begin
        if (new_frame) begin
            cnt2 <= 0;
        end
        else begin
            if (cnt2 < MAX2) begin
                cnt2 <= cnt2 + 1;
            end
            else begin
                if (cnt2 == MAX2) begin
                    $fclose(dcu_output_re);
                    $fclose(dcu_output_im);
                    $stop;
                end
            end
        end
    end

    integer     indx2;
    always @(posedge payload_clk) begin
        if (new_frame) begin
            indx2 <= 0;
        end
        else begin
            if (cnt2 >= VALUE3 && cnt2 <= VALUE4) begin
                if (cnt2%4==1) begin
                    indx2 <= indx2 + 1;
                end
            end
            else begin
                indx2 <= 0;
            end
        end
    end

    always @(posedge payload_clk) begin
        if (new_frame) begin
            payload_di_re <= 0;
            payload_di_im <= 0;
        end
        else begin
            payload_di_re <= payload_input_re[indx2];
            payload_di_im <= payload_input_im[indx2];
        end
    end

    always @(posedge payload_clk) begin
        if (new_frame) begin
            payload_di_vld <= 0;
        end
        else begin
            if (cnt2 >= VALUE3 && cnt2 <= VALUE4) begin
                if (cnt2%4==1) begin
                    payload_di_vld <= 1;
                end
                else begin
                    payload_di_vld <= 0;
                end
            end
            else begin
                payload_di_vld <= 0;
            end
        end
    end

    always @(posedge payload_clk) begin
        if (new_frame) begin
            payload_di_sym_end <= 0;
        end
        else begin
            if (cnt2 >= VALUE3 && cnt2 <= VALUE4) begin
                if ( cnt2%4==1 && (cnt2-1)%(4*480) == 0) begin
                    payload_di_sym_end <= 1;
                end
                else begin
                    payload_di_sym_end <= 0;
                end
            end
        end
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)  clk_o = ~clk_o;

    always @(posedge clk_o) begin
        if (do_vld) begin
            $fdisplay(dcu_output_re, "%b", do_re);
            $fdisplay(dcu_output_im, "%b", do_im);
        end
    end
	 
	 
	 
/*	 
	 always																				//Modified by baiyf
	 wait((cnt1==MAX1)&&(cnt2==MAX2)&&(frame_num<`NF-1))
	 begin
		begin
			new_frame=1;
			#1000 for(read_cnt=0;read_cnt<480;read_cnt=read_cnt+1) begin			
		       $fscanf(in_sig_r,"%b",signal_input_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<480;read_cnt=read_cnt+1) begin
		       $fscanf(in_sig_i,"%b",signal_input_im[read_cnt]);
			end
			for(read_cnt=0;read_cnt<2400;read_cnt=read_cnt+1) begin
		       $fscanf(in_pld_r,"%b",payload_input_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<2400;read_cnt=read_cnt+1) begin
		       $fscanf(in_pld_i,"%b",payload_input_im[read_cnt]);
			end
			new_frame=0;
			frame_num=frame_num+1;
		end
	 end
*/	 

endmodule