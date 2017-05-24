`timescale 1ns / 1ps
`include "global_define.vh"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:31:41 12/12/2016
// Design Name:   IFFT_CP
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_ifft_cp.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: IFFT_CP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_ifft_cp;

	// Inputs
	reg clk;
	reg new_frame;
	reg [11:0] di_re;
	reg [11:0] di_im;
	reg di_last;
	reg [3:0] di_sym_num;
	reg di_vld;

	// Outputs
	wire [11:0] do_re;
	wire [11:0] do_im;
	wire do_vld;

	// Instantiate the Unit Under Test (UUT)
	IFFT_CP uut (
		.clk(clk), 
		.new_frame(new_frame), 
		.di_re(di_re), 
		.di_im(di_im), 
		.di_last(di_last), 
		.di_sym_num(di_sym_num), 
		.di_vld(di_vld), 
		.do_re(do_re), 
		.do_im(do_im), 
		.do_vld(do_vld)
	);

	integer  ifft_cp_output_re;
   integer  ifft_cp_output_im;
	
/*	integer	frame_num=0;				//Modified by baiyf
	integer  in_data_re;
	integer  in_data_im;
	integer  read_cnt;
*/	
   reg  [11:0]  input_re  [0:3264-1];
   reg  [11:0]  input_im  [0:3264-1];

	initial begin
		// Initialize Inputs
		clk = 0;
		new_frame = 1;				//Modified by baiyf
		di_re = 0;
		di_im = 0;
		di_last = 0;
		di_sym_num = 6;
		di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		ifft_cp_output_re = $fopen("./debug_data/ifft_cp_output_re.dat", "w");
      ifft_cp_output_im = $fopen("./debug_data/ifft_cp_output_im.dat", "w");
      $readmemb("./debug_data/dcu_output_re.dat", input_re);							//Modified by baiyf
      $readmemb("./debug_data/dcu_output_im.dat", input_im);
/*		in_data_re=$fopen("./debug_data/dcu_output_re.dat","r+b");
		in_data_im=$fopen("./debug_data/dcu_output_im.dat","r+b");
		for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_re,"%b",input_re[read_cnt]);
		end
		for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		    $fscanf(in_data_im,"%b",input_im[read_cnt]);
		end
*/
		new_frame=0;
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2) clk = ~clk;

    integer  cnt = 0;
    localparam   MAX = 5000,
                 VALUE0 = 5,
                 VALUE1 = 30,
                 VALUE2 = VALUE1 + 3264 - 1;

    always @(posedge clk) begin
	 if(new_frame)						//Modified by baiyf
	 begin
		cnt<=0;
	 end
	 else begin
        if (cnt < MAX) begin
            cnt <= cnt + 1;
        end
        // if (cnt == VALUE0) begin
        //     new_frame <= 1;
        // end
        // else begin
        //     new_frame <= 0;
        // end

        // for debug
/*        if (cnt >= VALUE0 && cnt < VALUE0 + 3) begin			//Modified by baiyf
            new_frame <= 1;
        end
        else begin
            new_frame <= 0;
        end							
*/        
        else if (cnt == MAX) begin
            $fclose(ifft_cp_output_re);
            $fclose(ifft_cp_output_im);
            $stop;
        end
		end
    end
	 

    integer  indx;
    always @(posedge clk) begin
	 if(new_frame)							//Modified by baiyf
		 begin
			indx<=0;
		 end
	 else begin
			  if (cnt >= VALUE1 && cnt <= VALUE2) begin
					indx <= indx + 1;
			  end
			  else begin
					indx <= 0;
			  end
		 end
    end

    always @(posedge clk) begin
		 if(new_frame)begin				//Modified by baiyf
			  di_re<=0;
			  di_im<=0;
		 end
		 else begin
			  di_re <= input_re[indx];
			  di_im <= input_im[indx];
		 end
    end

    always @(posedge clk) begin
	 if(new_frame)							//Modified by baiyf
		 begin
			di_last<=0;
		 end
	 
		 else begin
			  if (indx == 512) begin
					di_last <= 1;
			  end
			  else if (indx > 512 && (indx-512)%544 == 0 ) begin
					di_last <= 1;
			  end
			  else begin
					di_last <= 0;
			  end
		 end
    end

    always @(posedge clk) begin
		if(new_frame)											//Modified by baiyf
		 begin
			di_vld<=0;
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

    //--------------------------------------------------------------------------

    always @(posedge clk) begin
        if (do_vld) begin
            $fdisplay(ifft_cp_output_re, "%b", do_re);
            $fdisplay(ifft_cp_output_im, "%b", do_im);
        end
    end
	 
/*	 always										//Modified by baiyf
	 wait((cnt==MAX)&&(frame_num<`NF-1))
	 begin
		begin
			new_frame=1;
			#1000 for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		       $fscanf(in_data_re,"%b",input_re[read_cnt]);
			end
			for(read_cnt=0;read_cnt<3264;read_cnt=read_cnt+1) begin
		       $fscanf(in_data_im,"%b",input_im[read_cnt]);
			end
			new_frame=0;
			frame_num=frame_num+1;
		end
	 end
*/
endmodule