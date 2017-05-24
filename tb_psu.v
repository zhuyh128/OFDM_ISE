`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:23:19 12/13/2016
// Design Name:   PSU
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_psu.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PSU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_psu;

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire packet_start;

	// Instantiate the Unit Under Test (UUT)
	PSU uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.do_re(do_re), 
		.do_im(do_im), 
		.packet_start(packet_start)
	);
	
	integer  psu_output_re;
   integer  psu_output_im;
/*	
	integer  in_data_re;		//Modified by baiyf
	integer  in_data_im;
	integer	frame_num=0;
	integer  read_cnt;
*/	
   reg  [11:0]     inputdata_re  [0:8880-1];				//Modified by baiyf 8860->8880
   reg  [11:0]     inputdata_im  [0:8880-1];

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di_re = 0;
		di_im = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		psu_output_re = $fopen("./debug_data/psu_output_re.dat", "w");				
      psu_output_im = $fopen("./debug_data/psu_output_im.dat", "w");
		
/*		in_data_re = $fopen("./debug_data/txout_output_re.dat","r+b");				//Modified by baiyf
		in_data_im = $fopen("./debug_data/txout_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin							
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end
*/		
      $readmemb("./debug_data/txout_output_re.dat", inputdata_re);
      $readmemb("./debug_data/txout_output_im.dat", inputdata_im);
      rst = 0;
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 10000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 8860 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(psu_output_re);
                $fclose(psu_output_im);
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

    //--------------------------------------------------------------------------

    always @(posedge clk) begin
        $fdisplay(psu_output_re, "%b", do_re);
        $fdisplay(psu_output_im, "%b", do_im);
    end
	 
/*	 always														//Modified by baiyf
	 begin
		 wait((cnt==MAX)&&(frame_num<`NF-1)) begin
			rst=1;
			#1000	for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<11037;read_cnt=read_cnt+1) begin
			    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
			end
			rst=0;
			frame_num=frame_num+1;
		 end
	 end
*/
endmodule