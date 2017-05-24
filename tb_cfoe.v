`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:29:16 12/13/2016
// Design Name:   CFOE
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_cfoe.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CFOE
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_cfoe;			

	// Inputs
	reg clk;
	reg rst;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg packet_start;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire cs_start;
	wire [17:0] cfo_estimated;
	wire cfo_estimated_vld;

	// Instantiate the Unit Under Test (UUT)
	CFOE uut (
		.clk(clk), 
		.rst(rst), 
		.di_re(di_re), 
		.di_im(di_im), 
		.packet_start(packet_start), 
		.do_re(do_re), 
		.do_im(do_im), 
		.cs_start(cs_start), 
		.cfo_estimated(cfo_estimated), 
		.cfo_estimated_vld(cfo_estimated_vld)
	);

	integer         cfoe_output_re;
   integer         cfoe_output_im;
   reg  [11:0]     inputdata_re  [0:10000-1];
   reg  [11:0]     inputdata_im  [0:10000-1];

/*	integer			 in_data_re;					//Modified by baiyf
	integer			 in_data_im;
	integer			 frame_num=0;
	integer			 read_cnt;
*/	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		di_re = 0;
		di_im = 0;
		packet_start = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		cfoe_output_re = $fopen("./debug_data/cfoe_output_re.dat", "w");
      cfoe_output_im = $fopen("./debug_data/cfoe_output_im.dat", "w");
      $readmemb("./debug_data/psu_output_re.dat", inputdata_re);			//Modified by baiyf
      $readmemb("./debug_data/psu_output_im.dat", inputdata_im);

/*		in_data_re = $fopen("./debug_data/psu_output_re.dat","r+b");
		in_data_im = $fopen("./debug_data/psu_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<10066;read_cnt=read_cnt+1) begin				
		    $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<10066;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
		end*/
      rst = 0;

    end

    //--------------------------------------------------------------------------
    
    always #(`CLK_PERIOD/2)    clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 11000,
                 VALUE1 = 5,
                 VALUE2 = VALUE1 + 10000 - 1;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(cfoe_output_re);
                $fclose(cfoe_output_im);
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

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            packet_start <= 0;
        end
        else begin
            // in the test, psu module ouput packet_start = 1392,
            // psu_output.dat has 1031 extra invalid data, so 1392 + 1031 = 2423
            if (indx == 2422) begin
                packet_start <= 1;
            end
            else begin
                packet_start <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    
    always @(posedge clk or posedge rst) begin
        $fdisplay(cfoe_output_re, "%b", do_re);
        $fdisplay(cfoe_output_im, "%b", do_im);
    end

/*	 always begin												//Modified by baiyf
		wait((cnt==MAX)&&(frame_num<`NF-1))
		begin
		    rst=1;
			 
			 #1000 for(read_cnt=0;read_cnt<10066;read_cnt=read_cnt+1) begin
			     $fscanf(in_data_re,"%b",inputdata_re[read_cnt]);
			 end
			 for(read_cnt=0;read_cnt<10066;read_cnt=read_cnt+1) begin
			     $fscanf(in_data_im,"%b",inputdata_im[read_cnt]);
			 end
			 rst=0;
			 frame_num=frame_num+1;
		end
	 end
*/
endmodule
