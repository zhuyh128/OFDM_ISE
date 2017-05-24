`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:56:55 12/12/2016
// Design Name:   CENC
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_cenc.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CENC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_cenc;

	// Inputs
	reg sce_clk_i;
	reg sce_clk_o;
	reg sce_rst;
	reg sce_di;
	reg [5:0] sce_di_init;
	reg sce_di_vld;
	reg pld_clk;
	reg pld_rst;
	reg pld_di;
	reg pld_di_vld;

	// Outputs
	wire sce_do;
	wire sce_do_vld;
	wire pld_do;
	wire pld_do_vld;
	wire [3:0] pld_do_sym_num;

	// Instantiate the Unit Under Test (UUT)
	CENC uut (
		.sce_clk_i(sce_clk_i), 
		.sce_clk_o(sce_clk_o), 
		.sce_rst(sce_rst), 
		.sce_di(sce_di), 
		.sce_di_init(sce_di_init), 
		.sce_di_vld(sce_di_vld), 
		.sce_do(sce_do), 
		.sce_do_vld(sce_do_vld), 
		.pld_clk(pld_clk), 
		.pld_rst(pld_rst), 
		.pld_di(pld_di), 
		.pld_di_vld(pld_di_vld), 
		.pld_do(pld_do), 
		.pld_do_vld(pld_do_vld), 
		.pld_do_sym_num(pld_do_sym_num)
	);
	integer  cenc_sig_output;
   integer  cenc_pld_output;
	
	integer  in_data_sig;				//Modified by baiyf
	integer  in_data_pld;
	integer  read_cnt;				
	integer  frame_num=0;
	
   reg signal  [0:32-1];				
   reg payload  [0:4320-1];
	
	
	
	initial begin
		// Initialize Inputs
		sce_clk_i = 0;
		sce_clk_o = 0;
		sce_rst = 1;
		sce_di = 0;
		sce_di_init = 0;
		sce_di_vld = 0;
		pld_clk = 0;
		pld_rst = 1;
		pld_di = 0;
		pld_di_vld = 0;

		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here
		cenc_sig_output = $fopen("./debug_data/cenc_sig_output.dat", "w");
      cenc_pld_output = $fopen("./debug_data/cenc_pld_output.dat", "w");
		
		in_data_sig=$fopen("./debug_data/obg_output.dat","r+b");					//Modified by baiyf
		in_data_pld=$fopen("./debug_data/obg_pld_output.dat","r+b");
		for(read_cnt=0;read_cnt<32;read_cnt=read_cnt+1)
		begin
			 $fscanf(in_data_sig,"%b",signal[read_cnt]);
		end
		
		for(read_cnt=0;read_cnt<4320;read_cnt=read_cnt+1)
		begin
		    $fscanf(in_data_pld,"%b",payload[read_cnt]);
		end				
		
		$readmemb("./debug_data/obg_output.dat",signal);
		$readmemb("./debug_data/obg_pld_output.dat",payload);

      sce_rst = 0;
      pld_rst = 0;
    end

    always #(`CLK_PERIOD/2*3) sce_clk_i = ~sce_clk_i;
    always #(`CLK_PERIOD/2)   sce_clk_o = ~sce_clk_o;
    always #(`CLK_PERIOD/2)   pld_clk   = ~pld_clk;

    //--------------------------------------------------------------------------
    // for signal input

    localparam  MAX = 10000,
                VALUE1 = 10,
                VALUE2 = VALUE1 + 32 - 1;
    integer  cnt;

    always @(posedge sce_clk_i or posedge sce_rst) begin
        if (sce_rst) begin
            // reset
            cnt <= 0;
        end
        else begin
            if (cnt < MAX) begin
                cnt <= cnt + 1;
            end
            if (cnt == MAX) begin
                $fclose(cenc_sig_output);
                $fclose(cenc_pld_output);
                $stop;
            end
        end
    end

    integer  indx;
    always @(posedge sce_clk_i) begin
        if (sce_rst) begin
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

    always @(posedge sce_clk_i or posedge sce_rst) begin
        if (sce_rst) begin
            sce_di <= 0;
        end
        else begin
            sce_di <= signal[indx];
        end
    end

    always @(posedge sce_clk_i or posedge sce_rst) begin
        if (sce_rst) begin
            // reset
            sce_di_init <= 0;
        end
        else begin
            if (cnt == VALUE1) begin
                sce_di_init <= 6'b111101;
            end
        end
    end

    always @(posedge sce_clk_i or posedge sce_rst) begin
        if (sce_rst) begin
            // reset
            sce_di_vld <= 0;
        end
        else begin
            if (cnt >= VALUE1 && cnt <= VALUE2) begin
                sce_di_vld <= 1;
            end
            else begin
                sce_di_vld <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // for payload input
    integer indx_pld;
    always @(posedge pld_clk) begin
        if (pld_rst) begin
            indx_pld <= 0;
        end
        else begin
            if (cnt >= 10 && indx_pld < 4319) begin
                indx_pld <= indx_pld + 1;
            end
            if (indx_pld == 4319) begin
                indx_pld <= 0;
            end
        end
    end

    // get payload input
    always @(posedge pld_clk or posedge pld_rst) begin
        if (pld_rst) begin
            pld_di <= 0;
        end
        else begin
            pld_di <= payload[indx_pld];
        end
    end

    // get payload input valid
    always @(posedge pld_clk or posedge pld_rst) begin
        if (pld_rst) begin
            // reset
            pld_di_vld <= 0;
        end
        else begin
            if (cnt >= 10  && cnt < 4330 ) begin
                pld_di_vld <= 1;
            end
            else begin
                pld_di_vld <= 0;
            end
        end
    end

/*    always @(posedge pld_clk or posedge pld_rst) begin
        if (pld_rst) begin
            // reset
            pld_rd_en <= 0;
        end
        else begin
            if (cnt == VALUE1) begin
                pld_rd_en <= 1;
            end
            else begin
                pld_rd_en <= 0;
            end
        end
    end*/




    // ------------------------------------------------------------------------
    // save result
    always @(posedge sce_clk_o or posedge sce_rst) begin
        if (sce_do_vld) begin
            $fdisplay(cenc_sig_output, "%b", sce_do);
        end
    end

    always @(posedge pld_clk or posedge pld_rst) begin
        if (pld_do_vld) begin
            $fdisplay(cenc_pld_output, "%b", pld_do);
        end
    end
	 
	 
	 always										//Modified by baiyf	
		wait((cnt==MAX)&&(frame_num<`NF-1))				
		begin
			sce_rst=1;
			pld_rst=1;
			
			#1000	
			for(read_cnt=0;read_cnt<32;read_cnt=read_cnt+1)
			begin
				$fscanf(in_data_sig,"%b",signal[read_cnt]);
			end
		
			for(read_cnt=0;read_cnt<4320;read_cnt=read_cnt+1)
			begin
				 $fscanf(in_data_pld,"%b",payload[read_cnt]);
			end
				
			sce_rst=0;
			pld_rst=0;
			frame_num=frame_num+1;
		end
			
endmodule
