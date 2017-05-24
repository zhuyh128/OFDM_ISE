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
module PCD(//������ļ��涨��ʼ����״̬�������뿪ʼ�����������Ϣ�������������̽�����ģ��inst_layed_cnp�����
				reset,//�����źţ����ڽ�������ɻ�����ֹδ��ɵ��������
				clk_in,//��ʱ���ź�����
				symbol_din,//���������
				frame_start,//���ź�ʹ��rece״̬��ʼ����ʼ��������������
				ldpc_dout,//�����������
				frame_finish//�������ֽ��ս�����־   
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

reg [13:0] rec_counter; //8640 ��14λ�����Ʊ�ʾ�к�
reg wea_init_rec;
reg [12:0] addr_dec_in; //����4320���,��Ϊֻ��ǰ4320����Ϣλ��֮���4320ֻ�Ǳ���ʱ����У��λ��û����

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

parameter [4:0] iter_times = 5'd12; //Ԥ�����Ҫ�������ܴ���������Ҫ�����12�Σ����ֵ��5λ�����Ʊ�ʾ
parameter [1:0] IDLE = 2'b00; 
parameter [1:0] RECE = 2'b01;
parameter [1:0] ITER = 2'b10;

reg [1:0] state;//��ע���������һ��Ҫ��IDLE����0��1����ʽ���ܱ�Ӳ��ʶ�𣬹�������ʾ״̬����һ״̬����һ���Ĵ�������
reg [1:0] next_state;
reg [4:0] iter_num;//�Ѿ���ɵĵ����Ĵ���

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
			rec_counter <= 14'h3fff;//14��1
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
	
	always @(state,frame_start,rec_finish,ldpc_finish) begin//������һ����������״̬��״̬��֮���ת����ϵ��һ��ʽ
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
		if(state != IDLE)  frame_finish <= ldpc_finish; //��ʱһ��clk_in
		else frame_finish <= 0; //����һ��ʱ��
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

layered_cnp inst_layered_cnp( //ע�⣺����������ģ�飬����Ҫ����ܽ�������һ�������д������������ʹ��
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

rom_for_col inst_col_rom(//���rom�����洢ƫ�����Ļ�����
   .clka(clk_in), 
   .addra(rom_addr),
   .douta(rom_in)
);

sum_ram inst_sum_ram(//��˫��RAM�Ķ˿���Ϣ�����ram����
  .clka(clk_in),//clka�˿ڶ�Ӧclk_in������д��ram��ʱ���źţ�֮��Ϊ�������������B�ڱ���ͬ����������ʹ��ͬһ·ʱ������clk_in
  .wea(sum_wea),//RAM��д��˿�A��дʹ���ź�
  .addra(sum_addra),//RAM��д��˿�A�ĵ�ַ
  .dina(sum_dina),//RAM��д��˿�A�����������
  .clkb(clk_in),
  .addrb(sum2dec_addr),//RAM�Ķ����˿�B�ĵ�ַ����sum2dec_addr��Ϊ��ַ����
  .doutb(sum_b)
);


vc_ram inst_vc_ram(//��˫��RAM�Ķ˿���Ϣ�����ram�����洢
   .clka(clk_in), //clka�˿ڶ�Ӧclk_in������д��ram��ʱ���źţ�֮��Ϊ�������������B�ڱ���ͬ����������ʹ��ͬһ·ʱ������clk_in
   .wea(extern_wea),//RAM��д��˿�A��дʹ���ź�
   .addra(extern_addra),//RAM��д��˿�A�ĵ�ַ��������ӵ�������Ϣ�ĵ�ַ
   .dina(extern_a),//RAM��д��˿�A����������ˣ�����������Ϣ������
   .clkb(clk_in),
   .addrb(extern_addrb),//RAM�Ķ����˿�B�ĵ�ַ
   .doutb(extern_b)//RAM�Ķ����˿�B����������ˣ�ram�ڵ����ݾ�A�ڽ���ĵ�ַ����Ѱַ��ͨ������������������
);
 

endmodule