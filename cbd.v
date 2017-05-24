`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 07/16/2016 02:59:16 PM
// Design Name: 
// Module Name: CBD
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implementation file of Computing Branch Distance(CBD) unit
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
//% CBD finish the branch distance computing(Euclidean Distance)

module CBD(
    input       clk,            //% working clock
    input       rst,            //% reset, active high

    input       [2:0] di,       //% input codewords for hard decode, 
                                //% input a codeword each time,g0->di[2]
    input       di_vld,         //% input data valid

    output reg  [1:0] do_0,     //% output 8 distance(for a codeword) for acs unit to select
    output reg  [1:0] do_1,     //% 
    output reg  [1:0] do_2,     //% 
    output reg  [1:0] do_3,     //% 
    output reg  [1:0] do_4,     //% 
    output reg  [1:0] do_5,     //% 
    output reg  [1:0] do_6,     //% 
    output reg  [1:0] do_7,     //% 
    output reg  do_vld          //% output data valid
    );
 
 // =========================================================================       
    // Main body of code


    reg [2:0] rec_codeword;      // rec_codeword[0] -> g0
    reg rec_codeword_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            rec_codeword <= 0;
            rec_codeword_vld <= 0;
        end
        else begin
            if (di_vld) begin
                rec_codeword_vld <= di_vld;
                rec_codeword <= di;
            end
            else begin
                rec_codeword <= 0;
                rec_codeword_vld <= 0;
            end
        end
    end

    reg [1:0] branch_met_tmp [0:7];
    reg branch_met_tmp_vld;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            branch_met_tmp[0] <= 0;
            branch_met_tmp[1] <= 0;
            branch_met_tmp[2] <= 0;
            branch_met_tmp[3] <= 0;
            branch_met_tmp[4] <= 0;
            branch_met_tmp[5] <= 0;
            branch_met_tmp[6] <= 0;
            branch_met_tmp[7] <= 0;
        end
        else begin                
            if (rec_codeword_vld) begin
                // hamming distance between rec_codeword and 000(possible codeword)
                branch_met_tmp[0] <= {1'b0,rec_codeword[2]} + {1'b0,rec_codeword[1]} + {1'b0,rec_codeword[0]};
                // hamming distance between rec_codeword and 001(possible codeword)
                branch_met_tmp[1] <= {1'b0,rec_codeword[2]} + {1'b0,rec_codeword[1]} + {1'b0,~rec_codeword[0]};
                // hamming distance between rec_codeword and 010(possible codeword)
                branch_met_tmp[2] <= {1'b0,rec_codeword[2]} + {1'b0,~rec_codeword[1]} + {1'b0,rec_codeword[0]};
                // hamming distance between rec_codeword and 011(possible codeword)
                branch_met_tmp[3] <= {1'b0,rec_codeword[2]} + {1'b0,~rec_codeword[1]} + {1'b0,~rec_codeword[0]};
                // hamming distance between rec_codeword and 100(possible codeword)
                branch_met_tmp[4] <= {1'b0,~rec_codeword[2]} + {1'b0,rec_codeword[1]} + {1'b0,rec_codeword[0]};
                // hamming distance between rec_codeword and 101(possible codeword)
                branch_met_tmp[5] <= {1'b0,~rec_codeword[2]} + {1'b0,rec_codeword[1]} + {1'b0,~rec_codeword[0]};
                // hamming distance between rec_codeword and 110(possible codeword)
                branch_met_tmp[6] <= {1'b0,~rec_codeword[2]} + {1'b0,~rec_codeword[1]} + {1'b0,rec_codeword[0]};
                // hamming distance between rec_codeword and 111(possible codeword)
                branch_met_tmp[7] <= {1'b0,~rec_codeword[2]} + {1'b0,~rec_codeword[1]} + {1'b0,~rec_codeword[0]};
              
            end
            else begin
                branch_met_tmp[0] <= 0;
                branch_met_tmp[1] <= 0;
                branch_met_tmp[2] <= 0;
                branch_met_tmp[3] <= 0;
                branch_met_tmp[4] <= 0;
                branch_met_tmp[5] <= 0;
                branch_met_tmp[6] <= 0;
                branch_met_tmp[7] <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            branch_met_tmp_vld <= 0;
        end
        else begin
            if (rec_codeword_vld) begin
                branch_met_tmp_vld <= rec_codeword_vld;
            end
            else begin
                branch_met_tmp_vld <= 0;
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_0 <= 0;
            do_1 <= 0;
            do_2 <= 0;
            do_3 <= 0;
            do_4 <= 0;
            do_5 <= 0;
            do_6 <= 0;
            do_7 <= 0;
            do_vld <= 0;
        end
        else begin
            if (branch_met_tmp_vld) begin
                do_0 <= branch_met_tmp[0];
                do_1 <= branch_met_tmp[1];
                do_2 <= branch_met_tmp[2];
                do_3 <= branch_met_tmp[3];
                do_4 <= branch_met_tmp[4];
                do_5 <= branch_met_tmp[5];
                do_6 <= branch_met_tmp[6];
                do_7 <= branch_met_tmp[7];
                do_vld <= branch_met_tmp_vld;
            end
            else begin
                do_0 <= 0;
                do_1 <= 0;
                do_2 <= 0;
                do_3 <= 0;
                do_4 <= 0;
                do_5 <= 0;
                do_6 <= 0;
                do_7 <= 0;
                do_vld <= 0;
            end
        end
    end
 
endmodule
