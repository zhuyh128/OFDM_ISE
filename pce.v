`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2016 03:48:46 PM
// Design Name: 
// Module Name: PCE(Payload Channel Encode)
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module PCE(            //前级要有能保��320的fifo，编码结束将encode_busy变为0，这时候从fifo读入新的一帧编码数�    
	 done_rst,
    clk,                //% working clock
    rst,                //% reset active high
    din,                //% input origin payload data
    din_valid,          //% input payload data valid
    data_valid,         //% output encoded data valid 
    encode_out,         //% output encode data
    encode_busy
    );
    
	 input									done_rst;
    input                           clk;
    input                           rst;
    input                           din;
    input                           din_valid;
    
    output                      data_valid;         //编码结果输出信号，应该和encode_out对齐
    output                      encode_out;
    output                      encode_busy;
    
    wire                    rst_n;
    reg         [12:0]      counter;
    wire        [12:0]      counter1;           //一方面作为写入存储信息位的inbuff的地址，另一方面作为输入到各个编码器的当前输入信息位的位�    
	 wire        [12:0]      out_addr_indicate;
    wire                        calculate_finish;
    reg         [3:0]           num;
    reg         [3:0]           num1;
    reg         [8:0]           out_addr_check;
    wire        [8:0]           out_addr_check1;
    reg                         data_valid_info;
    reg                         encode_out_reg;
    reg                         data_valid_check;
    wire                        data_valid_check1;
    
    reg                         data_valid_infos1;
    reg                         data_valid_infos2;
    reg                         data_valid_checks2;
    reg                         data_valid_checks1;
    reg                         encode_infos2;
    reg                         encode_infos1;
    reg                         din_valids3;
    reg                         din_valids2;
    reg                         din_valids1;
    
    reg         [12:0]      out_addr_info;
    wire        [12:0]      out_addr_info1;
    wire                            rst_roc;
    wire                            encode_info;
    wire                            dout1,dout2,dout3,dout4,dout5,dout6,dout7,dout8,dout9,dout10,dout11,dout12;
    
    assign          rst_n = ~rst;

    assign          counter1 = counter;
    assign          out_addr_indicate = {num,out_addr_check};
    assign          rst_roc = (num1 == 4'd12)? 1'b0 : 1'b1;
    assign          rst_n_all  = rst_n  && rst_roc;
    assign          out_addr_info1 = out_addr_info;
    assign          out_addr_check1 = out_addr_check;
    assign          data_valid_check1 = data_valid_check;
    assign          data_valid = data_valid_infos2 || data_valid_checks2;
    assign          encode_out = (data_valid_infos2)? encode_infos2 : encode_out_reg;
    assign          encode_busy = din_valid || din_valids3 || data_valid;
        
    always @(posedge clk ) begin
        if(!rst_n_all)  
            counter <= 13'd0;   
        else begin
            if(din_valid)  begin
                if(counter == 13'd4319)
                    counter <= counter;
                else  counter <= counter + 1'b1;
            end
            else counter <= counter;
        end
    end


    always @(posedge clk) begin
      if(!rst_n_all)  
            data_valid_info <= 1'b0;
        else begin
            if((calculate_finish == 1'b1) && (out_addr_info != 13'd4320))
                data_valid_info <= 1'b1;
            else    data_valid_info <= 1'b0;
        end
    end


    always @(posedge clk) begin   //out_addr_check要从359变化�，这是因为累加结果的最高位是输出的第一�        
		if(!rst_n_all) begin
            out_addr_check <= 9'd359;
            num <= 4'd0;
        end
        else begin
            if(data_valid_check)  begin       //在输出完信息位作为编码结果之后，开始输出校验位，这里使用data_valid_check作为整个输出过程的标�                
				    if(out_addr_check == 9'd0) begin
                    out_addr_check <= 9'd359;
                    num <= num + 1'b1;
                end
                else out_addr_check <= out_addr_check - 1'b1;
            end
            else begin
                out_addr_check <= 9'd359;
                num <= 4'd0;
            end
        end
    end
    
    always @(posedge clk) begin   //num1为num的延�        
		if(!rst_n_all) begin
            num1 <= 4'b0;
        end
        else begin
            num1 <= num;
        end
    end
    
    always @(posedge clk) begin   //data_valid_infos1为data_valid_info的延�        
	 if(!rst_n_all) begin
            data_valid_infos1 <= 1'b0;
        end
        else begin
            data_valid_infos1 <= data_valid_info;
        end
    end

    always @(posedge clk) begin   //data_valid_infos2为data_valid_infos1的延�        
	 if(!rst_n_all) begin
            data_valid_infos2 <= 1'b0;
        end
        else begin
            data_valid_infos2 <= data_valid_infos1;
        end
    end

    always @(posedge clk) begin   //data_valid_checks1为data_valid_check的延�        
	 if(!rst_n_all) begin
            data_valid_checks1 <= 1'b0;
        end
        else begin
            data_valid_checks1 <= data_valid_check;
        end
    end

    always @(posedge clk) begin   //data_valid_checks2为data_valid_checks1的延�       
	 if(!rst_n_all) begin
            data_valid_checks2 <= 1'b0;
        end
        else begin
            data_valid_checks2 <= data_valid_checks1;
        end
    end

    always @(posedge clk) begin   //encode_infos1为encode_info的延�        
	 if(!rst_n_all) begin
            encode_infos1 <= 1'b0;
        end
        else begin
            encode_infos1 <= encode_info;
        end
    end

    always@(posedge clk)    begin   //encode_infos2为encode_infos1的延�            
	 if(!rst_n_all)  begin
                encode_infos2 <= 1'b0;
            end
        else  begin
                encode_infos2 <= encode_infos1;
            end
    end

    always@(posedge clk ) begin   //din_valids1为din_valid的延�        
	 if(!rst_n_all) begin
            din_valids1 <= 1'b0;
        end
        else begin
            din_valids1 <= din_valid;
        end
    end

    always@(posedge clk) begin   //din_valids2为din_valids1的延�       
	 if(!rst_n_all) begin
            din_valids2 <= 1'b0;
        end
        else begin
            din_valids2 <= din_valids1;
        end
    end

    always@(posedge clk ) begin   //din_valids3为din_valids2的延�       
	 if(!rst_n_all) begin
            din_valids3 <= 1'b0;
        end
        else begin
            din_valids3 <= din_valids2;
        end
    end
    
    
    
    always@(posedge clk) begin
        if(!rst_n_all) begin
            out_addr_info <= 13'b0;
            data_valid_check <= 1'b0;
        end
        else  begin
            if(calculate_finish) begin           //在叠加计算结束之后才开始输出信息位
                if((out_addr_info == 13'd4320) && (out_addr_indicate != 13'h1600))
                    data_valid_check <= 1'b1;           //这里不将out_addr_info置零，只在重置信号的时候变�
                else begin
                    data_valid_check <= 1'b0;
                    out_addr_info <= out_addr_info + 1'b1;
                end
            end
            else begin       //calculate_finish = 1'b0
                out_addr_info <= 13'b0;
                data_valid_check <= 1'b0;
            end
        end
    end
    
    
    always@(posedge clk )    begin
        if(!rst_n_all)
            encode_out_reg <= 1'b0;
        else  begin
            case(num1)
                4'd0 :  encode_out_reg <= dout1;
                4'd1 :  encode_out_reg <= dout2;
                4'd2 :  encode_out_reg <= dout3;
                4'd3 :  encode_out_reg <= dout4;
                4'd4 :  encode_out_reg <= dout5;
                4'd5 :  encode_out_reg <= dout6;
                4'd6 :  encode_out_reg <= dout7;
                4'd7 :  encode_out_reg <= dout8;
                4'd8 :  encode_out_reg <= dout9;
                4'd9 :  encode_out_reg <= dout10;
                4'd10 :  encode_out_reg <= dout11;
                4'd11 :  encode_out_reg <= dout12;
            endcase
        end
    end
	 
    inbuff inbuff_inst(     //4320 information bits，一边编码，一边写入inbuff，也就是说din_valid可以作为它的写入wea信号
        .clka(clk),
        .wea(din_valid),
        .addra(counter1),
        .dina(din),
        .clkb(clk),
        .addrb(out_addr_info1),             //最终输出编码结果的时候，先要读出原始信息位，这里为读出地址，也是先入先出的 0-4319
        .doutb(encode_info)         
    );

    encoder1 encoder_inst1(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout1),           //1bit
        .calculate_finish(calculate_finish)
    );

    encoder2 encoder_inst2(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout2)            //1bit
    );

    encoder3 encoder_inst3(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout3)
    );

    encoder4 encoder_inst4(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout4)
    );

    encoder5 encoder_inst5(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout5)
    );

    encoder6 encoder_inst6(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout6)
    );

    encoder7 encoder_inst7(
        .clk(clk),
        .rst_n(!done_rst||rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout7)
    );

    encoder8 encoder_inst8(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout8)
    );

    encoder9 encoder_inst9(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout9)
    );

    encoder10 encoder_inst10(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout10)
    );

    encoder11 encoder_inst11(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout11)
    );

    encoder12 encoder_inst12(
        .clk(clk),
        .rst_n(rst_n_all),
        .din_valid(din_valid),
        .din(din),      //1bit
        .counter(counter1),
        .out_addr(out_addr_check1),
        .data_valid_check(data_valid_check1),
        .dout(dout12)
    );


endmodule

