`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:28:51 02/25/2015 
// Design Name: 
// Module Name:    ldpc_decoder_8640 
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
module PCD(//顶层的文件规定初始化，状态机，译码开始结束的相关信息，具体的译码过程交给子模块inst_layed_cnp来完成
				reset,//重置信号，用于结束已完成或者终止未完成的译码过程
				clk_in,//总时钟信号输入
				symbol_din,//码字输入端
				frame_start,//本信号使得rece状态开始，开始读入待译码的码字
				ldpc_dout,//译码结果输出端
				frame_finish//待译码字接收结束标志   
    );

input reset;
input clk_in; 
input frame_start;
output frame_finish;
input [7:0] symbol_din; 
output [0:0] ldpc_dout;


reg ldpc_finish; 
reg frame_finish;
reg rec_start;
reg rec_finish;  

reg [13:0] rec_counter; //8640 用14位二进制表示列号
reg wea_init_rec;
reg [12:0] addr_dec_in; //读出4320结果,因为只有前4320是信息位，之后的4320只是编码时生成校验位，没有用

wire sum_wea;
wire [13:0] sum_addra;
wire [9:0] sum_dina;
wire sum_wea1;
wire [13:0] sum_addra1;
wire [9:0] sum_a1;
wire [13:0] sum_addrb;
wire [9:0] sum_b;

wire extern_wea;
wire [14:0] extern_addra;
wire [7:0] extern_a;
wire [14:0] extern_addrb;
//wire [13:0] extern_addrb1;
wire [7:0] extern_b;
wire [7:0] extern_b1;

wire [6:0] rom_addr;
wire [22:0] rom_in;  
wire cnp_ok;

reg active_cnp;
wire reset_cnp;
assign reset_cnp = reset || !active_cnp;

parameter [4:0] iter_times = 5'd12; //预设的需要迭代的总次数，这里要求迭代12次，这个值用5位二进制表示
parameter [1:0] IDLE = 2'b00; 
parameter [1:0] RECE = 2'b01;
parameter [1:0] ITER = 2'b10;

reg [1:0] state;//需注意的是这里一定要把IDLE赋成0和1的形式才能被硬件识别，故用来表示状态和下一状态都用一个寄存器保存
reg [1:0] next_state;
reg [4:0] iter_num;//已经完成的迭代的次数

reg  done_rst;													//Modified by baiyf
reg  done_flag;

always @(posedge clk_in or posedge reset or posedge done_rst) begin
	if(reset||done_rst) begin
		state <= IDLE;
	end
	else 
	begin 
		state <= next_state; 
	end
end

always @(reset,frame_start,rec_finish,done_rst) begin
	if(reset||done_rst) begin
		rec_start <= 0;
	end
	else begin
		if(frame_start) begin
			rec_start <= 1;
		end
		if(rec_finish) begin
			rec_start <= 0;
		end
	end
end

  always @(posedge clk_in or posedge reset or posedge done_rst) begin
		if(reset||done_rst) begin
			rec_finish <= 1'b0;
			rec_counter <= 14'h3fff;//14个1
			wea_init_rec <= 1'b0;
		end
		else begin
			if(frame_start==1'b1 || rec_start) begin
				if(rec_counter != 14'd8639) begin
					rec_counter <= rec_counter + 1;
					wea_init_rec <= 1'b1;
				end
				else begin
					if(ldpc_finish)  rec_counter <= 14'h3fff;
					else rec_counter <= rec_counter;
				end
			end
			else begin
			end
			if(rec_counter == 14'd8639) rec_finish <= 1'b1;
			else rec_finish <= rec_finish;
			if(rec_finish) wea_init_rec <= 1'b0;
		end
	end
	
	always @(state,frame_start,rec_finish,ldpc_finish) begin//描述了一个具有三种状态的状态机之间的转换关系，一段式
		case(state)
		IDLE: begin
			if(frame_start) next_state <= RECE;
			else next_state <= IDLE;
		end
		RECE: begin
			if(rec_finish) next_state <= ITER;
			else next_state <= RECE;
		end
		ITER: begin
			if(ldpc_finish) next_state <= IDLE;
			else next_state <= ITER;
		end
		endcase
	end	
	
	
	always @(posedge clk_in or posedge reset or posedge done_rst) begin
		if(reset||done_rst) begin
			ldpc_finish <= 1'b0;
			iter_num <= 5'd0;
			active_cnp <= 1'b0;
		end
		else begin
			case(state)
				IDLE: begin
					iter_num <= 5'd0;
					active_cnp <= 1'b0;
				end
				RECE: begin
					ldpc_finish <= 1'b0;
				end
				ITER: begin
					if(cnp_ok) begin  
		//				iter_num <= iter_num +1;
						if(iter_num == iter_times -1) 
						begin
							ldpc_finish <= 1'b1;
						end
						else iter_num <= iter_num +1;
						
						active_cnp <= 1'b0;
					end
					else active_cnp <= 1'b1;
				end
			endcase
		end
	end
	
always @(posedge clk_in or posedge reset or posedge done_rst) begin
	if(reset||done_rst) begin
		addr_dec_in <= 13'd0;
		frame_finish <= 1'b0;
	end
	else begin
		if(state != IDLE)  frame_finish <= ldpc_finish; //延时一个clk_in
		else frame_finish <= 0; //保持一个时钟
		if(ldpc_finish) begin
			if(addr_dec_in < 13'd4320) addr_dec_in <= addr_dec_in +1;
		end
		else begin
			addr_dec_in <= 13'd0;
		end
	end
end
/*
always @(negedge out_dec or posedge reset or posedge done_rst) begin				//Modified by baiyf
	if(reset||done_rst) begin
	    done_flag <= 0;
	end
	else begin
	    done_flag <= 1;
	end
end

always @(posedge clk_in) begin															  //Modified by baiyf
	if(done_flag) begin
	    done_rst <= 1;
	end
	else begin
	    done_rst <= 0;
	end
end
*/    
assign sum_wea = (state!=ITER)? wea_init_rec : sum_wea1;
assign sum_addra = (state!=ITER)? rec_counter : sum_addra1;
assign sum_dina = (state!=ITER)? {symbol_din[7],symbol_din[7],symbol_din} : sum_a1;

assign ldpc_dout = (state!=ITER)?sum_b[9]:0;


assign extern_b1 = (iter_num==0)? 0 : extern_b;
wire [13:0] sum2dec_addr;
assign sum2dec_addr = (state==ITER)? sum_addrb : {1'b0,addr_dec_in};

layered_cnp inst_layered_cnp( //注意：调用例化的模块，必须要将其管脚依次序一个不差的写出来才能正常使用
	.clk(clk_in),
	.rst(reset_cnp||done_rst),
	.cnp_finish(cnp_ok),
	.cnp_data_r(extern_b1),
	.cnp_addr_r(extern_addrb),
	.cnp_data_w(extern_a),
	.cnp_addr_w(extern_addra),
	.wea_cnp_w(extern_wea),
	.rom_addr(rom_addr),
	.rom_in(rom_in),
	.sum_addr_i(sum_addrb),
	.sum_in(sum_b),
	.sum_addr_o(sum_addra1),
	.sum_out(sum_a1),
	.sum_wea(sum_wea1)
);

rom_for_col inst_col_rom(//这个rom用来存储偏移量的基矩阵？
   .clka(clk_in), 
   .addra(rom_addr),
   .douta(rom_in)
);

sum_ram inst_sum_ram(//简单双口RAM的端口信息（这个ram用来
  .clka(clk_in),//clka端口对应clk_in用作读写入ram的时钟信号，之后为了与数据输出端B口保持同步，故两者使用同一路时钟输入clk_in
  .wea(sum_wea),//RAM的写入端口A的写使能信号
  .addra(sum_addra),//RAM的写入端口A的地址
  .dina(sum_dina),//RAM的写入端口A的数据输入端
  .clkb(clk_in),
  .addrb(sum2dec_addr),//RAM的读出端口B的地址，用sum2dec_addr作为地址变量
  .doutb(sum_b)
);


vc_ram inst_vc_ram(//简单双口RAM的端口信息（这个ram用来存储
   .clka(clk_in), //clka端口对应clk_in用作读写入ram的时钟信号，之后为了与数据输出端B口保持同步，故两者使用同一路时钟输入clk_in
   .wea(extern_wea),//RAM的写入端口A的写使能信号
   .addra(extern_addra),//RAM的写入端口A的地址，这里相接的是外信息的地址
   .dina(extern_a),//RAM的写入端口A的数据输入端，这里是外信息的数据
   .clkb(clk_in),
   .addrb(extern_addrb),//RAM的读出端口B的地址
   .doutb(extern_b)//RAM的读出端口B的数据输出端，ram内的数据经A口进入的地址进行寻址后通过这里把数据输出出来
);
 

endmodule