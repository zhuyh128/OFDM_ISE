`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 07/19/2016 11:26:16 AM
// Design Name: 
// Module Name: GRC(Get Receive Codeword)
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implemention file of the Get Receive Codeword(GRC) Unit 
// 
// Dependencies: 
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// =============================================================================
// Module Declaration
// 
//% Get Receive Codeword(GRC) module divide the receive signal bits(96) into 32 groups,
//% 3 bits each group, per group represent a receive code word. 
//% the outputs are continuous(in time domain)
//
//% the output   do[2]->g0, do[1]->g1, do[0]->g2
//% 

module GRC(
    input         clk,
    input         rst,

    input         di,
    input         di_vld,

    output reg    [2:0] do,
    output reg    do_vld
    );

  // ----------------------------------------------------------------------
    // Main body of the Code 
   
  reg [95:0] save_data;
  reg [6:0] indx;

  localparam MAX = `SIGNAL_CODED_LEN - 1;

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          // reset
          indx <= 0;
      end
      else begin
          if (di_vld) begin
              if (indx == MAX) begin
              indx <= indx;
              end
              else if (indx < MAX) begin
              indx <= indx + 1;
              end
          end
          else begin
              indx <= 0;
          end
      end
  end

  reg [6:0] in_cnt;

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          // reset
          save_data <= 0;
          in_cnt <= 0;
      end
      else begin
          if (di_vld) begin
              save_data[indx] <= di;
              in_cnt <= in_cnt + 1;
          end
      end
  end

  reg [4:0] out_cnt;
  reg out_en;
  
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          // reset
          out_en <= 0;
      end
      else begin
          if (in_cnt == MAX && out_cnt < (`DEPTH - 1)) begin
              out_en <= 1;
          end
          if (out_cnt == (`DEPTH - 1)) begin
              out_en <= 0;
          end
      end
  end

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          // reset
          do <= 0;
          out_cnt <= 0;
      end
      else begin
          if (out_en) begin
              do[0] <= save_data[3 * out_cnt + 2];
              do[1] <= save_data[3 * out_cnt + 1];
              do[2] <= save_data[3 * out_cnt];
              out_cnt <= out_cnt + 1;
          end
      end
  end

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          // reset
          do_vld <= 0;
      end
      else begin
          do_vld <= out_en;
      end
  end

    

endmodule
