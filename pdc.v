`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2016 03:59:32 PM
// Design Name: 
// Module Name: TMP
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


module PDC(
    input clk,
    input rst,
    input signed [7:0] di,
    input di_vld,
    output reg signed [7:0] do,
    output reg do_vld
    );
    
    wire full;
    reg wr_en;
    reg signed [7:0] din;

    reg [13:0] wr_cnt;
    localparam WR_CNT_MAX = 8640;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_en <= 0;
            din <= 0;
        end
        else begin
            if (di_vld && !full) begin
                if (wr_cnt == WR_CNT_MAX) begin
                    wr_en <= 0;
                    din <= 0;
                end
                else begin
                    wr_en <= 1;
                    din <= di;
                end
            end
            else begin
                wr_en <= 0;
                din <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wr_cnt <= 14'd0;
        end
        else begin
            if (di_vld && !full) begin
                if (wr_cnt < WR_CNT_MAX) begin
                    wr_cnt <= wr_cnt + 1;
                end
            end
            else begin
                wr_cnt <= 14'd0;
            end
        end
    end

    wire         empty;
    wire signed [7:0]  dout;
    reg          rd_en;
    wire         valid;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rd_en <= 0;
        end
        else begin
            if (wr_cnt == WR_CNT_MAX - 2) begin  // read latency = 2
                rd_en <= 1;
            end
            else if (empty) begin
                rd_en <= 0;
            end
            else begin
                rd_en <= rd_en;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do <= 0;
        end
        else begin
            if (valid) begin
                do <= dout;
            end
        end
    end

    // reg do_tmp_vld1;
    // reg do_tmp_vld2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            // do_tmp_vld1 <= 0;
            // do_tmp_vld2 <= 0;
            do_vld <=0;
        end
        else begin
            // do_tmp_vld1 <= valid;
            // do_tmp_vld2 <= do_tmp_vld1;
            do_vld <= valid;
        end
    end


    PDC_FIFO U_PDC_FIFO (
      .clk(clk),      // input wire clk
      .rst(rst),      // input wire rst
      .din(din),      // input wire [7 : 0] din
      .wr_en(wr_en),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout),    // output wire [7 : 0] dout
      .full(full),    // output wire full
      .empty(empty),  // output wire empty
      .valid(valid)  // output wire valid
    );

endmodule
