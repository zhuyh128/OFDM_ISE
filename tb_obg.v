`timescale 1ns / 1ps
`include "global_define.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:48:27 12/12/2016
// Design Name:   OBG
// Module Name:   E:/study/projects/ise-projects/OFDM/tb_obg.v
// Project Name:  OFDM
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: OBG
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_obg;

	// Inputs
	reg ssg_clk;
	reg ssg_rst;
	reg [15:0] ssg_di_len;
	reg [3:0] ssg_di_type;
	reg ssg_di_vld;
	reg new_frame;
	reg pld_clk;
	reg pld_rst;

	// Outputs
	wire [5:0] ssg_do_init;
	wire ssg_do;
	wire ssg_do_vld;
	wire pld_do;
	wire pld_do_vld;

	// Instantiate the Unit Under Test (UUT)
	OBG uut (
		.ssg_clk(ssg_clk), 
		.ssg_rst(ssg_rst), 
		.ssg_di_len(ssg_di_len), 
		.ssg_di_type(ssg_di_type), 
		.ssg_di_vld(ssg_di_vld), 
		.ssg_do_init(ssg_do_init), 
		.ssg_do(ssg_do), 
		.ssg_do_vld(ssg_do_vld), 
		.new_frame(new_frame), 
		.pld_clk(pld_clk), 
		.pld_rst(pld_rst), 
		.pld_do(pld_do), 
		.pld_do_vld(pld_do_vld)
	);

	integer  obg_output;
   integer obg_pld_output;
	
	integer frame_num=0;				//Modified by baiyf
   // signal bits
   reg  signal_bits  [0:31];
	 
	initial begin
		// Initialize Inputs
		ssg_clk = 0;
		ssg_rst = 1;
		ssg_di_len = 0;
		ssg_di_type = 0;
		ssg_di_vld = 0;
		new_frame = 0;
		pld_clk = 0;
		pld_rst = 1;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
        obg_output = $fopen("./debug_data/obg_output.dat","w");
        obg_pld_output = $fopen("./debug_data/obg_pld_output.dat","w");
        $readmemb("./debug_data/signal.dat", signal_bits);
        ssg_rst = 0;
        pld_rst = 0;

        #50;
        new_frame = 1;

        #`CLK_PERIOD;
        new_frame = 0;
    end

    //--------------------------------------------------------------------------

    always #(`CLK_PERIOD/2*3)  ssg_clk = ~ssg_clk;
    always #(`CLK_PERIOD/2)    pld_clk = ~pld_clk;

    integer  cnt = 0;
    localparam   MAX = 1500,
                 VALUE1 = 20;

    // for signal
    always @(posedge ssg_clk) begin
        if (ssg_rst) begin
            cnt <= 0;
        end
        else begin
            if (cnt == MAX) begin
                $fclose(obg_output);
                $fclose(obg_pld_output);
                $stop;
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

    always @(posedge ssg_clk) begin
        if (ssg_rst) begin
            // reset
            ssg_di_len <= 0;
            ssg_di_type <= 0;
            ssg_di_vld <= 0;
        end
        else begin
            if (cnt == VALUE1) begin
                ssg_di_type[0] <= signal_bits[8];
                ssg_di_type[1] <= signal_bits[9];
                ssg_di_type[2] <= signal_bits[10];
                ssg_di_type[3] <= signal_bits[11];
                ssg_di_len[0] <= signal_bits[12];
                ssg_di_len[1] <= signal_bits[13];
                ssg_di_len[2] <= signal_bits[14];
                ssg_di_len[3] <= signal_bits[15];
                ssg_di_len[4] <= signal_bits[16];
                ssg_di_len[5] <= signal_bits[17];
                ssg_di_len[6] <= signal_bits[18];
                ssg_di_len[7] <= signal_bits[19];
                ssg_di_len[8] <= signal_bits[20];
                ssg_di_len[9] <= signal_bits[21];
                ssg_di_len[10] <= signal_bits[22];
                ssg_di_len[11] <= signal_bits[23];
                ssg_di_len[12] <= signal_bits[24];
                ssg_di_len[13] <= signal_bits[25];
                ssg_di_len[14] <= signal_bits[26];
                ssg_di_len[15] <= signal_bits[27];
            end
            if (cnt == VALUE1 + 1) begin
                ssg_di_vld <= 1;
                new_frame <= 1;
            end
            else begin
                ssg_di_vld <= 0;
                new_frame <= 0;
            end
        end
    end

    always @(posedge ssg_clk) begin
        if (ssg_do_vld) begin
            $fdisplay(obg_output, "%b", ssg_do);
        end
    end


    // for payload
    always @(posedge pld_clk) begin
        if (pld_do_vld) begin
            $fdisplay(obg_pld_output,"%b",pld_do);
        end
    end
/*	 
	 always                                        //Modified by bai
		wait((cnt==MAX)&&(frame_num<`NF-1))			  
		begin
					pld_rst=1;
					ssg_rst=1;
					
					#1000 pld_rst=0;
					ssg_rst=0;
					frame_num=frame_num+1;
		end
*/		
	always @(posedge pld_clk or posedge ssg_clk) begin
		if((cnt==MAX)&&(frame_num<`NF-1)) begin
			ssg_rst <= 1;
			pld_rst <= 1;
			#1000 ssg_rst <= 0;
			pld_rst <= 0;
			frame_num=frame_num+1;
		end
	end
endmodule
