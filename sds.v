`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 08/01/2016 04:26:44 PM
// Design Name: 
// Module Name: SDS
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implementation file of Smaller Distance Select(SDS) Unit
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SDS(   
    input [11:0] di_dis0,
    input [11:0] di_dis1,
    input [5:0] di_state0,
    input [5:0] di_state1,
    output [11:0] do_dis,
    output [5:0] do_state
    );
    
    // function to compare two distance
    function [11:0] find_smaller_distance;
    input [11:0] di_dis0;
    input [11:0] di_dis1;
    begin
        if (di_dis0 < di_dis1) begin
            find_smaller_distance = di_dis0;
        end
        else begin
            find_smaller_distance = di_dis1;
        end
    end
    endfunction

    // function to get survivor(get smaller/better state)
    function [5:0] find_smaller_state;
    input [11:0] di_dis0;
    input [11:0] di_dis1;
    input [5:0] di_state0;
    input [5:0] di_state1;
    begin
        if (di_dis0 < di_dis1) begin
            find_smaller_state = di_state0;
        end
        else begin
            find_smaller_state = di_state1;
        end
    end
    endfunction

    // get the compare result
    assign do_dis = find_smaller_distance(di_dis0,di_dis1);
    assign do_state = find_smaller_state(di_dis0,di_dis1,di_state0,di_state1);

endmodule
