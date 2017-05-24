`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:09:19 12/13/2016
// Design Name:   RECV
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_recv.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: RECV
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_recv;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;

	// Outputs
	wire do_signal;
	wire do_signal_vld;
	wire do_payload;
	wire do_payload_vld;

	// Instantiate the Unit Under Test (UUT)
	RECV uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.do_signal(do_signal), 
		.do_signal_vld(do_signal_vld), 
		.do_payload(do_payload), 
		.do_payload_vld(do_payload_vld)
	);
	
	reg  [11:0]     inputdata_re  [0:8880-1];				//Modified by baiyf
   reg  [11:0]     inputdata_im  [0:8880-1];
   integer         recv_output;
   integer         recv_s_output;

	integer			 in_data_re;	//Modified by baiyf
	integer         in_data_im;
	integer         frame_num=0;
	integer         read_cnt;

   reg out_dec;
   reg [13:0] addr_dec_in;
	
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		addr_dec_in = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		recv_output = $fopen("./debug_data/recv_output.dat", "w");
      recv_s_output = $fopen("./debug_data/recv_s_output.dat","w");
		
//      $readmemb("./debug_data/txout_output_re.dat", inputdata_re);				//Modified by baiyf
//      $readmemb("./debug_data/txout_output_im.dat", inputdata_im);
		in_data_re = $fopen("./debug_data/txout_output_re.dat","r+b");
		in_data_im = $fopen("./debug_data/txout_output_im.dat","r+b");
		
		for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end
		
      rst = 0;
    end

    //--------------------------------------------------------------------------
	 
    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 500000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 8860 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(recv_output);
                $fclose(recv_s_output);
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
            di_re <= 0;
            di_im <= 0;
        end
        else begin
            di_re <= inputdata_re[indx];
            di_im <= inputdata_im[indx];
        end
    end

    // for  output
    always @(do_payload_vld or posedge clk) begin
        if (rst) begin
            // reset
            out_dec <= 0;
        end
        else begin
            if (do_payload_vld) begin
                out_dec <= 1;
            end
            if (addr_dec_in == 4319) begin
                out_dec <= 0;
            end
        end
    end

    // // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (out_dec) begin
            if (addr_dec_in != 4319) begin
                addr_dec_in <= addr_dec_in + 1;
                $fdisplay(recv_output,"%b",do_payload);
            end
        end
        else begin
            addr_dec_in <= 14'h3fff;
        end
    end

    //--------------------------------------------------------------------------

    always @(posedge clk) begin
        if (do_signal_vld) begin
            $fdisplay(recv_s_output, "%b", do_signal);
        end
    end
	 
	 always begin													//Modified by baiyf
	     wait((cnt==MAX)&&(frame_num<`NF-1)) begin
		     rst=1;
			  #1000 for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
					$fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
			  end
			  for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
					$fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
			  end
			  rst=0;
			  frame_num=frame_num+1;
		  end
	 end
	 
	 
	 
endmodule
