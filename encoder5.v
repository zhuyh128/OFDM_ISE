`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:37 05/10/2016 
// Design Name: 
// Module Name:    encoder5 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module encoder5(
		clk,
		rst_n,
		din_valid,
		din,
		counter,
		out_addr,
		data_valid_check,
		dout
    );
	 
	 input 					clk;
	 input					rst_n;
	 input					din_valid;
	 input					din;
	 input		[12:0]	counter;
	 input		[8:0]		out_addr;	//从359到0倒序变化，因为结果的最高位是译码结结果的第一位
	 input					data_valid_check;//1是作为输出的选择信号，当这个输入为1的时候就按次序输出编码结果,要在信息位输出之后才变为1
	 
	 output					dout;

	 
	 reg			[359:0]		sum_temp;
	 wire			[359:0]		rom_out;
	 reg			[359:0]		rom_out_temp;
	 reg			[3:0]			addra_reg;
	 wire			[3:0]			addra;
	 wire							cnt;
	 reg							out_temp;
	 
	 assign			dout	 = out_temp;
	 assign			cnt	 = (counter == 13'd359) ||(counter == 13'd719) || (counter == 13'd1079) || (counter == 13'd1439) || (counter == 13'd1799) || (counter == 13'd2159) || (counter == 13'd2519) || (counter == 13'd2879) || (counter == 13'd3239) || (counter == 13'd3599) || (counter == 13'd3959) || (counter == 13'd4319);
	 assign			addra	 = addra_reg;
	 
		always@(posedge clk)	begin
			if(!rst_n)
				sum_temp <= 360'b0;
			else begin
				if(din_valid)	begin
						if(din)	sum_temp <= sum_temp ^ rom_out_temp ;		//如果输入的是1那么就将进行逐次异或
							else     sum_temp <= sum_temp;
					end
				else	sum_temp <= sum_temp;
				end
		end
		
		always@(posedge clk)	begin
				if(!rst_n)
					rom_out_temp <= rom_out;
				else   begin
					if(din_valid) begin
						if(cnt)
							rom_out_temp <= rom_out;
						else
							rom_out_temp <= {rom_out_temp[0],rom_out_temp[359:1]};
						end
				end
		end
		
		always@(posedge clk)	begin
				if(counter <= 13'd356)
					addra_reg <= 4'd0;
				else if(counter <= 13'd716)
					addra_reg <= 4'd1;
				else if(counter <= 13'd1076)
					addra_reg <= 4'd2;
				else if(counter <= 13'd1436)
					addra_reg <= 4'd3;
				else if(counter <= 13'd1796)
					addra_reg <= 4'd4;
				else if(counter <= 13'd2156)
					addra_reg <= 4'd5;
				else if(counter <= 13'd2516)
					addra_reg <= 4'd6;
				else if(counter <= 13'd2876)
					addra_reg <= 4'd7;
				else if(counter <= 13'd3236)
					addra_reg <= 4'd8;
				else if(counter <= 13'd3596)
					addra_reg <= 4'd9;	
				else if(counter <= 13'd3956)
					addra_reg <= 4'd10;
				else if (counter <= 13'd4316)
					addra_reg <= 4'd11;
				else addra_reg <= 4'd0;
			
		end
	
	
		always@(posedge clk)	begin			//输出校验位开始后，逐位输出译码结果
			if(data_valid_check)	
					out_temp <= sum_temp[out_addr];
			else 	out_temp <= 1'b0;
		end
		
		
		
				
	G_rom5 G_rom5_inst(
	.clka(clk),
	.addra(addra),
	.douta(rom_out)
	);

endmodule
