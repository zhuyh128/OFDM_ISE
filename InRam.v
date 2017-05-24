`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 08/04/2016 09:43:21 AM
// Design Name: 
// Module Name: INRAM
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: store the input codewords into a RAM(just to test, to be moved to gop)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Module Declaration
//
//% store the input codewords into a RAM(just to test, can be removed)

module INRAM(
    input       clk,            //% working clock
    input       rst,            //% reset, active high
    input       [2:0] di,       //% input received codedwords
    input       di_vld,         //% input data valid

    output reg  [2:0] do,       //% output received codewords
    output reg  do_vld          //% output data valid
    );


    // ------------------------------------------------------------------
    // save input data into RAM
    // 
    reg wea;
    reg [4:0] addra;
    reg [2:0] dina;
    reg [4:0] in_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wea <= 0;
            addra <= 5'b1_1111;
            dina <= 0;
        end
        else begin
            wea <= di_vld;
            dina <= di;
            if (di_vld) begin
                addra <= addra + 1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            in_cnt <= 0;
        end
        else begin
            if (di_vld) begin
                if (in_cnt < (`DEPTH - 1)) begin
                    in_cnt <= in_cnt + 1;
                end
            end
            else begin
                in_cnt <= in_cnt;
            end
        end
    end

    // -----------------------------------------------------------------------

    reg read_en;
    reg [1:0] iteration;

    reg read_en_tmp1;
    reg read_en_tmp2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            read_en <= 0;

            read_en_tmp1 <= 1;
            read_en_tmp2 <= 1;
            iteration <= 0;
        end
        else begin
            if (in_cnt < (`DEPTH - 1)) begin
                read_en <= 0;      // read out after all datas are written
            end
            else begin
                read_en <= 1;      // need to be modified
                if (iteration == 3) begin
                    read_en_tmp2 <= 0;
                    read_en_tmp1 <= read_en_tmp2;
                    read_en <= read_en_tmp1;
                end
                else begin
                    if (out_cnt == (`DEPTH - 1)) begin
                        iteration <= iteration + 1;
                    end
                end
                
            end
        end
    end

    // read out the codewords from RAM
    reg [4:0] addrb;
    wire [2:0] doutb;
    reg [4:0] out_cnt;
    reg doutb_vld;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt <= 0;
        end
        else begin
            if (read_en) begin
                out_cnt <= out_cnt + 1;
            end
            else begin
                out_cnt <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addrb <= 5'b1_1111;
        end
        else begin
            if (read_en) begin
                addrb <= addrb + 1;
            end
        end
    end
    
    // final output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            if (read_en) begin
                do <= doutb;
            end
        end
    end

    reg do_vld_tmp1;
    reg do_vld_tmp2;
    reg do_vld_tmp3;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
            do_vld_tmp1 <= 0;
            do_vld_tmp2 <= 0;
            do_vld_tmp3 <= 0;
        end
        else begin
            if (read_en) begin
                do_vld_tmp1 <= read_en;
                do_vld_tmp2 <= do_vld_tmp1;
                do_vld_tmp3 <= do_vld_tmp2;
                do_vld <= do_vld_tmp3;
            end
            else begin
                do_vld_tmp1 <= 0;
                do_vld_tmp2 <= 0;
                do_vld_tmp3 <= 0;
                do_vld <= 0;
            end
        end
    end

    
    // instantiate the ip core
    IN_RAM U_IN_RAM (
      .clka(clk),    // input wire clka
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [4 : 0] addra
      .dina(dina),    // input wire [2 : 0] dina
      .clkb(clk),    // input wire clkb
      .addrb(addrb),  // input wire [4 : 0] addrb
      .doutb(doutb)  // output wire [2 : 0] doutb
    );

endmodule
