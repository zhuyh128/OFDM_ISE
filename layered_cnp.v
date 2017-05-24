`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:26:17 03/04/2015 
// Design Name: 
// Module Name:    layered_cnp 
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
module layered_cnp(
			 clk,
			 rst,
			 cnp_finish,
			 cnp_data_r,
			 cnp_addr_r,
			 cnp_data_w,
			 cnp_addr_w,
			 wea_cnp_w,
			 rom_addr,
			 rom_in,
			 sum_addr_i,
			 sum_in,
			 sum_addr_o,
			 sum_out,
			 sum_wea//将求和结果写到RAM里的写使能信号  
    );

input  clk; 
input  rst;
output cnp_finish;

input  [7:0]  cnp_data_r;
output [14:0] cnp_addr_r;
output [7:0]  cnp_data_w;
output [14:0] cnp_addr_w;
output        wea_cnp_w;

output [6:0] rom_addr;
input [22:0] rom_in;//从rom里读出的数
output [13:0] sum_addr_i;
input [9:0] sum_in;
output [13:0] sum_addr_o;
output [9:0] sum_out;
output sum_wea;

reg cnp_finish;
reg [14:0] cnp_addr_r;
reg [12:0] row_counter_r; //用于读,4320
reg [12:0] row_counter_w; //用于写
reg [4:0] cnp_cnt; //用来迭代次数指示
reg [8:0] inblock_cnt; //用来块内计数，360
reg [8:0] inblock_cnt_w; //用来写RAM时块内计数，360
reg [3:0] block_num_r;
reg [3:0] block_num_w; //指示当前进行译码的行所在的基矩阵号

always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnp_cnt <= 5'd0;
		cnp_finish <= 1'b0;
	end
	else begin
		if(cnp_cnt == 16) begin
			if(inblock_cnt_w==9'd359) cnp_cnt <= 5'd0;  
			else cnp_cnt <= 5'd9; 
			if(row_counter_w==13'd4319) cnp_finish <= 1'b1;
		end
		else begin
			cnp_cnt <= cnp_cnt + 1;
		end
	end
end

reg [22:0] rom_in_tmp0;//缓存计算的rom中间变量寄存器
reg [22:0] rom_in_tmp1;
reg [22:0] rom_in_tmp2;
reg [22:0] rom_in_tmp3;
reg [22:0] rom_in_tmp4;
reg [22:0] rom_in_tmp5;
reg [22:0] rom_in_tmp6;
reg [2:0] tmp_rom; //用于指示读第几个rom
//reg [3:0] block_num;  
assign rom_addr = (block_num_w<<3) - block_num_w + tmp_rom;

always @(posedge clk or posedge rst) begin //这个模块是用来读取ROM里面的数据，这个rom里的数据是从基矩阵得到的查找表，其格式为
	if(rst) begin                           //{H矩阵中的某一行的1的位置（列号用14位表示）连上移位系数信息（9位，最多为359），这个移位系数是这片360*360整体的移位，其后一行是这个+1}
		tmp_rom <= 3'd0;                     //这也是为什么之后有个判断是否到了360，到了360，下一行的1就在这片的开头了
		rom_in_tmp0 <= 23'd0;                //开始将缓存计算的rom中间变量寄存器全部置零
		rom_in_tmp1 <= 23'd0;
		rom_in_tmp2 <= 23'd0;
		rom_in_tmp3 <= 23'd0;
		rom_in_tmp4 <= 23'd0;
		rom_in_tmp5 <= 23'd0;
		rom_in_tmp6 <= 23'd0;
	end
	else begin
		case(cnp_cnt)
		0: begin
			tmp_rom <= 3'd0;
		end
		1: begin
			tmp_rom <= 3'd1;
		end
		2: begin
			tmp_rom <= 3'd2;
			rom_in_tmp0 <= rom_in;
		end
		3: begin
			tmp_rom <= 3'd3;
			rom_in_tmp1 <= rom_in;
		end
		4: begin
			tmp_rom <= 3'd4;
			rom_in_tmp2 <= rom_in;
		end
		5: begin
			tmp_rom <= 3'd5;
			rom_in_tmp3 <= rom_in;
		end
		6: begin
			tmp_rom <= 3'd6;
			rom_in_tmp4 <= rom_in;
		end
		7: begin
			rom_in_tmp5 <= rom_in;
		end
		8: begin
			rom_in_tmp6 <= rom_in;
		end
		endcase
	end
end

wire [8:0] yy;
assign yy = 9'b101101000 - inblock_cnt;
reg [22:0] rom_in_tmpr;
wire [13:0] addr_r_tmp;
assign addr_r_tmp = (rom_in_tmpr[8:0] < yy) ? (rom_in_tmpr[22:9]+inblock_cnt) : (rom_in_tmpr[22:9] - yy);
assign sum_addr_i = addr_r_tmp;

reg [2:0] tmp_vc; 
//assign cnp_addr_r = (row_counter_r<<3)-row_counter_r + tmp_vc; //读VC_RAM的地址计算

wire [10:0] extern_10bit;

//parameter [5:0] up_threshhold = 6'b011111;
//parameter [5:0] down_threshhold = 6'b100001;
assign extern_10bit = {sum_in[9],sum_in} - {cnp_data_r[7],cnp_data_r[7],cnp_data_r[7],cnp_data_r}; //计算外信息
//wire [7:0] extern_abs;
//assign extern_abs = extern_8bit[7]? (256-extern_8bit): extern_8bit;
//reg [7:0] extern_abs;
reg [7:0] data_in_abs;
reg data_in_flag;
always @(posedge clk or posedge rst) begin //导致往后移
	if( rst) begin
		//extern_abs <= 8'd0;
		data_in_abs <= 8'd0;
		data_in_flag <= 1'b0;
	end
	else begin
		//extern_abs <= extern_8bit[7]? (256-extern_8bit): extern_8bit;
		data_in_flag <= extern_10bit[10];
		case(extern_10bit[10])
		1: begin
			if(extern_10bit < 11'b11110000001) data_in_abs <= 8'b01111111;
			else data_in_abs <= 2048-extern_10bit;
		end
		0: begin
			if(extern_10bit> 11'b00001111111) data_in_abs  <= 8'b01111111;
			else data_in_abs <= extern_10bit[7:0];
		end
		endcase
	end
end

//wire [5:0] data_in_abs;
//wire data_in_flag;
//assign data_in_abs = (extern_abs>8'b00011111)? 6'b011111 : extern_abs[5:0];
//assign data_in_flag = extern_8bit[7];

reg [9:0] rho_0;//由于每一行的1的个数最多为7，所以乘积最多为7个非零的值，这里用7个寄存器变量代表它们
reg [9:0] rho_1;//由于行重最多为7，所以ROM里写入不足7的行时用0补上，这样就可以一次性的读7个，不用管行重的不规则性
reg [9:0] rho_2;
reg [9:0] rho_3;
reg [9:0] rho_4;
reg [9:0] rho_5;
reg [9:0] rho_6;

reg [7:0] min;       //用于存储每行的最小值
reg [7:0] sec_min;   //用于存储每行的次小值
reg [2:0] min_num;   //用于存储最小值的序号
reg flag_sum;        //用于累计每行的符号和
reg [6:0] data_flag; //用于存储每行每个数的符号

reg [7:0] min_1;       //这里必须复制每一行的信息，不然在这一行读的时候会将上一行的信息更新掉了的，而上一行还没有写完，因此会出现错误
reg [7:0] sec_min_1;   
reg [2:0] min_num_1;   
reg flag_sum_1;        
reg [6:0] data_flag_1; 

reg [2:0] notzero_num;
reg [2:0] notzero_num1;
				
always @(posedge clk or posedge rst) begin //这个模块是用来读ram的
	if(rst) begin
		tmp_vc <= 3'd0;
		rom_in_tmpr <= 23'd0;
		rho_0 <= 10'd0;
		rho_1 <= 10'd0;
		rho_2 <= 10'd0;
		rho_3 <= 10'd0;
		rho_4 <= 10'd0;
		rho_5 <= 10'd0;
		rho_6 <= 10'd0;
		min <= 8'd0;
		sec_min <= 8'd0;
		min_num <= 3'd0;
		flag_sum <= 1'b0;
		data_flag <= 7'd0;
		min_1 <= 8'd0;
		sec_min_1 <= 8'd0;
		min_num_1 <= 3'd0;
		flag_sum_1 <= 1'b0;
		data_flag_1 <= 7'd0;
		row_counter_r <= 13'd0;
		inblock_cnt <= 9'd0;
		block_num_r <= 4'd0;
		tmp_vc <= 3'd0;  
	end
	else begin
		case(cnp_cnt)
		7: begin
			//tmp_vc <= 3'd0;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 0; 
			rom_in_tmpr <= rom_in_tmp0;
		end
		8: begin
			//tmp_vc <= 3'd1;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 1; 
			rom_in_tmpr <= rom_in_tmp1;
		end
		9: begin
			//tmp_vc <= 3'd2;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 2; 
			rom_in_tmpr <= rom_in_tmp2;
		//	rho_0 <= extern_8bit;
			//读进第0个数vc_ram，读进第0个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_0 <= 10'b0111111111;
				else 
					rho_0 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_0 <= 10'b1000000001;
				else 
				rho_0 <= extern_10bit[9:0];
			end
			endcase
			
		end
		10: begin
			//tmp_vc <= 3'd3;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 3; 
			rom_in_tmpr <= rom_in_tmp3;
		//	rho_1 <= extern_10bit;
			//读进第1个数vc_ram，读进第1个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit > 11'b00111111111) 
					rho_1 <= 10'b0111111111;
				else 
					rho_1 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_1 <= 10'b1000000001;
				else 
				rho_1 <= extern_10bit[9:0];
			end
			endcase
			
			min <= data_in_abs;
			min_num <= 3'd0;
			flag_sum <= data_in_flag;
			data_flag[0] <= data_in_flag; //初始化min，以及序号
			
		end
		11: begin
			//tmp_vc <= 3'd4;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 4; 
			rom_in_tmpr <= rom_in_tmp4;
		//	rho_2 <= extern_8bit;
			//读进第2个数vc_ram，读进第2个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_2 <= 10'b0111111111;
				else 
					rho_2 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_2 <= 10'b1000000001;
				else 
				rho_2 <= extern_10bit[9:0];
			end
			endcase
			flag_sum <= flag_sum + data_in_flag;
			data_flag[1] <= data_in_flag;
			if(data_in_abs <= min) begin
				sec_min <= min;
				min <= data_in_abs;
				min_num <= 3'd1;
			end
			else begin
				sec_min <= data_in_abs;
			end                            //比较第1个数
			
		end
		12: begin
			//tmp_vc <= 3'd5;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 5; 
			rom_in_tmpr <= rom_in_tmp5;
		//	rho_3 <= extern_10bit;
			//读进第3个数vc_ram，读进第3个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_3 <= 10'b0111111111;
				else 
					rho_3 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_3 <= 10'b1000000001;
				else 
				rho_3 <= extern_10bit[9:0];
			end
			endcase
			
			flag_sum <= flag_sum + data_in_flag;
			data_flag[2] <= data_in_flag;
		//	if(data_in_abs <= min) begin
		//		sec_min <= min;
		//		min <= data_in_abs;
		//		min_num <= 3'd2;
		//	end
		//	else if(data_in_abs < sec_min) begin
		//		sec_min <= data_in_abs;
		//	end	                          //比较第2个数
			if(data_in_abs < sec_min) begin
				if(data_in_abs <= min)begin
					sec_min <= min;
					min <= data_in_abs;
					min_num <= 3'd2;
				end
				else sec_min <= data_in_abs;
			end	                          //比较第2个数
		end
		13: begin
			//tmp_vc <= 3'd6;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 6; 
			rom_in_tmpr <= rom_in_tmp6;
		//	rho_4 <= extern_10bit;
			//读进第4个数vc_ram，读进第4个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_4 <= 10'b0111111111;
				else 
					rho_4 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_4 <= 10'b1000000001;
				else 
				rho_4 <= extern_10bit[9:0];
			end
			endcase
			
			flag_sum <= flag_sum + data_in_flag;
			data_flag[3] <= data_in_flag;
//			if(data_in_abs <= min) begin
//				sec_min <= min;
//				min <= data_in_abs;
//				min_num <= 3'd3;
//			end
//			else if(data_in_abs<sec_min) begin
//				sec_min <= data_in_abs;
//			end                              //比较第3个数	
			if(data_in_abs < sec_min) begin
				if(data_in_abs <= min)begin
					sec_min <= min;
					min <= data_in_abs;
					min_num <= 3'd3;
				end
				else sec_min <= data_in_abs;
			end	                          //比较第3个数
		end
		14: begin			
		//	rho_5 <= extern_10bit;	
			//读进第5个数vc_ram，读进第5个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_5 <= 10'b0111111111;
				else 
					rho_5 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_5 <= 10'b1000000001;
				else 
				rho_5 <= extern_10bit[9:0];
			end
			endcase
			
			flag_sum <= flag_sum + data_in_flag;
			data_flag[4] <= data_in_flag;
//			if(data_in_abs<=min) begin
//				sec_min <= min;
//				min <= data_in_abs;
//				min_num <= 3'd4;
//			end
//			else if(data_in_abs<sec_min) begin
//				sec_min <= data_in_abs;
//			end	                           //比较第4个数
			if(data_in_abs < sec_min) begin
				if(data_in_abs <= min)begin
					sec_min <= min;
					min <= data_in_abs;
					min_num <= 3'd4;
				end
				else sec_min <= data_in_abs;
			end	                          //比较第4个数
		end
		15: begin
			//tmp_vc <= 3'd0;  //这里空了一个时钟进行运算
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 7; 
			rom_in_tmpr <= rom_in_tmp0;
			if(inblock_cnt_w!=9'd359) begin
				row_counter_r <= row_counter_r + 1; //////////////行读的计数器+1
				if(inblock_cnt != 9'd359) inblock_cnt <= inblock_cnt + 1;
				else begin
					inblock_cnt <= 0;
					block_num_r <= block_num_r + 1;
				end
			end
			
		//	rho_6 <= extern_10bit; 
			//读进第6个数vc_ram，读进第6个sum
			case(extern_10bit[10])
			0: begin
				if(extern_10bit >11'b00111111111) 
					rho_6 <= 10'b0111111111;
				else 
					rho_6 <= extern_10bit[9:0];
			end
			1:begin
				if(extern_10bit < 11'b11000000001) 
				rho_6 <= 10'b1000000001;
				else 
				rho_6 <= extern_10bit[9:0];
			end
			endcase
			
						
			if(notzero_num >=6) begin
				flag_sum <= flag_sum + data_in_flag;
				data_flag[5] <= data_in_flag;
//				if(data_in_abs<=min) begin
//					sec_min <= min;
//					min <= data_in_abs;
//					min_num <= 3'd5;
//				end
//				else if(data_in_abs<sec_min) begin
//					sec_min <= data_in_abs;
//				end										//比较第5个数
				if(data_in_abs < sec_min) begin
					if(data_in_abs <= min)begin
						sec_min <= min;
						min <= data_in_abs;
						min_num <= 3'd5;
					end
					else sec_min <= data_in_abs;
				end	                          //比较第5个数
			end                                  
			
		end
		16: begin
			//tmp_vc <= 3'd1;
			cnp_addr_r <= (row_counter_r<<3)-row_counter_r + 1; 
			rom_in_tmpr <= rom_in_tmp1;
			
			/*if(notzero_num ==7) begin
				flag_sum <= flag_sum + data_in_flag;
				data_flag[6] <= data_in_flag;
				if(data_in_abs<=min) begin
					sec_min <= min;
					min <= data_in_abs;
					min_num <= 3'd6;
				end
				else if(data_in_abs<sec_min) begin
					sec_min <= data_in_abs;
				end
			end                                  //比较第6个数
			
			min_1 <= min;
			sec_min_1 <= sec_min;
			min_num_1 <= min_num;
			flag_sum_1 <= flag_sum;
			data_flag_1 <= data_flag;*/
			if(notzero_num ==7) begin
				flag_sum_1 <= flag_sum + data_in_flag;
				data_flag_1 <= {data_in_flag,data_flag[5:0]};
//				if(data_in_abs<=min) begin
//					sec_min_1 <= min;
//					min_1 <= data_in_abs;
//					min_num_1 <= 3'd6;
//				end
//				else if(data_in_abs<sec_min) begin
//					sec_min_1 <= data_in_abs;
//				end
				if(data_in_abs < sec_min) begin
					if(data_in_abs <= min)begin
						sec_min_1 <= min;
						min_1 <= data_in_abs;
						min_num_1 <= 3'd6;
					end
					else begin
						min_1 <= min;
						sec_min_1 <= data_in_abs;
						min_num_1 <= min_num;
					end
				end	                          //比较第6个数
				else begin
					min_1 <= min;
					sec_min_1 <= sec_min;
					min_num_1 <= min_num;
				end
			end                                  //比较第6个数
			else begin
				min_1 <= min;
				sec_min_1 <= sec_min;
				min_num_1 <= min_num;
				flag_sum_1 <= flag_sum;
				data_flag_1 <= data_flag;
			end
		end			

		endcase
	end
end


reg wea_cnp_w;
reg [7:0] cnp_data_w;
reg sum_wea;

reg [9:0] rho;
reg [2:0] tmp_wr;
assign cnp_addr_w = (row_counter_w<<3)-row_counter_w + tmp_wr;

wire [9:0] out_data;   
wire [7:0] out_data1; //将要输出的数据和符号分别out_data1和out_flag
//reg [5:0] out_data1;
wire [0:0] out_flag;//代表out_flag只用1位二进制表示
assign out_data = out_flag? (1024 - (out_data1<<1)-out_data1) : ((out_data1<<1)+out_data1);//这里将计算补码以及扩大3倍合成一个电路去计算  2 非关键路径

wire [8:0] xx;
assign xx = 9'b101101000 - inblock_cnt_w;
reg [22:0] rom_in_tmp;
wire [13:0] addr_w_tmp;
assign addr_w_tmp = (rom_in_tmp[8:0] < xx)? (rom_in_tmp[22:9] + inblock_cnt_w) : (rom_in_tmp[22:9] - xx);
assign sum_addr_o = addr_w_tmp;

wire [10:0] sum_out1;
assign sum_out1 = {rho[9],rho} + {out_data[9],out_data[9],out_data[9],out_data[9:2]}; //需要再加饱和处理！！！ 3
reg [9:0] sum_out;

reg write_en;
reg [2:0] tmp_num;
assign out_data1 = (min_num_1 == tmp_num)? sec_min_1 : min_1;  //1
assign out_flag = flag_sum_1 + data_flag_1[tmp_num];

always @(posedge clk or posedge rst) begin //用来写数据回vc_ram和sum_ram
	if(rst) begin
		tmp_wr <= 3'd0;
		wea_cnp_w <= 1'b0;
		cnp_data_w <= 8'd0;
		rom_in_tmp <= 23'd0;
		rho <= 10'd0;
		sum_wea <= 1'b0;
		write_en <= 1'b0;
		row_counter_w <= 13'd0;
		tmp_num <= 3'd0;
		sum_out <= 10'd0;
		block_num_w <= 4'd0;
		inblock_cnt_w <= 9'd0;
	end
	else begin
		case(cnp_cnt) 
		8: begin
			write_en <= 1'b0;
		end
		9: begin
			tmp_wr <= 3'd0;
			rom_in_tmp <= rom_in_tmp0; 
			
			if(write_en)begin
				sum_wea <= 1'b1;
				wea_cnp_w <= 1'b1;
			end
			cnp_data_w <= out_data[9:2];     //第0个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd1;
		//	out_data1 <= (min_num_1 == 0)? sec_min_1 : min_1;
			
			rho <= rho_1;
		end
		10: begin
			tmp_wr <= 3'd1;
			rom_in_tmp <= rom_in_tmp1; 
			
			cnp_data_w <= out_data[9:2];     //第1个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd2;
		//	out_data1 <= (min_num_1 == 1)? sec_min_1 : min_1;
			
			rho <= rho_2;
		end
		11: begin
			tmp_wr <= 3'd2;
			rom_in_tmp <= rom_in_tmp2; 
			
			cnp_data_w <= out_data[9:2];     //第2个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd3;
		//	out_data1 <= (min_num_1 == 2)? sec_min_1 : min_1;
			
			rho <= rho_3;
		end
		12: begin
			tmp_wr <= 3'd3;
			
			rom_in_tmp <= rom_in_tmp3; 
			
			cnp_data_w <= out_data[9:2];     //第3个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd4;
		//	out_data1 <= (min_num_1 == 3)? sec_min_1 : min_1;
			
			rho <= rho_4;
		end
		13: begin
			tmp_wr <= 3'd4;
			rom_in_tmp <= rom_in_tmp4; 
			
			cnp_data_w <= out_data[9:2];     //第4个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd5;
		//	out_data1 <= (min_num_1 == 4)? sec_min_1 : min_1;
			
			rho <= rho_5;
		end
		14: begin
			tmp_wr <= 3'd5;
			rom_in_tmp <= rom_in_tmp5; 
			
			if(write_en && notzero_num1 >=6) begin
				wea_cnp_w <= 1'b1;
				sum_wea <= 1'b1;
			end
			else begin
				wea_cnp_w <= 1'b0;          //这里要加一个判断
				sum_wea <= 1'b0;
			end
			
			cnp_data_w <= out_data[9:2];     //第5个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
			tmp_num <= 3'd6;
		//	out_data1 <= (min_num_1 == 5)? sec_min_1 : min_1;
			rho <= rho_6;
		end
		15: begin
			tmp_wr <= 3'd6;
			rom_in_tmp <= rom_in_tmp6; 
			
			if(write_en  && notzero_num1 ==7) begin
				wea_cnp_w <= 1'b1;
				sum_wea <= 1'b1;
			end
			else begin
				wea_cnp_w <= 1'b0;          //判断
				sum_wea <= 1'b0;
			end
			cnp_data_w <= out_data[9:2];     //第6个数存储
			//sum_out <= sum_out1;
			case(sum_out1[10])
			0:begin
				if(sum_out1>11'b00111111111) 
						sum_out <= 10'b0111111111;
				else 
						sum_out <= sum_out1[9:0];
			end
			1:begin
				if(sum_out1<11'b11000000001) 
						sum_out <= 10'b1000000001;
				else 
						sum_out <= sum_out1[9:0];
			end
			endcase
		end
		16: begin
			if(write_en) begin
				row_counter_w <= row_counter_w + 1;
				if(inblock_cnt_w != 9'd359) 
					inblock_cnt_w <= inblock_cnt_w + 1;
				else 
				begin
				   inblock_cnt_w <= 0;
					block_num_w <= block_num_w + 1; 
				end
			end
			if(write_en==0) write_en <= 1'b1;
			tmp_num <= 3'd0; 
		//	out_data1 <= (min_num_1 == 0)? sec_min_1 : min_1;
			
			rho <= rho_0;
			
			wea_cnp_w <= 1'b0; 
		   sum_wea <= 1'b0;
		end
		
		endcase
	end
end

always @(rst,block_num_w) begin
	if(rst) begin
		notzero_num = 3'd0;
	end
	else begin
		case(block_num_w)
		0: notzero_num = 3'd5;
		3: notzero_num = 3'd6;
		5: notzero_num = 3'd6;
		6: notzero_num = 3'd6;
		7: notzero_num = 3'd6;
		9: notzero_num = 3'd6;
		default: notzero_num = 3'd7;	
		endcase
	end
end 

always @(rst,block_num_w) begin
	if(rst) begin
		notzero_num1 = 3'd0;
	end
	else begin
		case(block_num_w)
		0: notzero_num1 = 3'd5;
		3: notzero_num1 = 3'd6;
		5: notzero_num1 = 3'd6;
		6: notzero_num1 = 3'd6;
		7: notzero_num1 = 3'd6;
		9: notzero_num1 = 3'd6;
		default: notzero_num1 = 3'd7;	
		endcase
	end
end 

endmodule
