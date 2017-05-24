`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MITC
// Engineer: xu
// 
// Create Date: 08/09/2016 09:02:49 AM
// Design Name: 
// Module Name: TBU
// Project Name: OFDM
// Target Devices: 
// Tool Versions: 
// Description: brief implementation file of Trace Back Unit(TBU)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TRACE(
    input [63:0] di_sur_path,       // survive path, read from RAM, from DEPTH to first(time)
    input [5:0] di_cur_state,  // current state(traceback initial state is from SDS Unit)
                               // others are from the module self
    
    output do_sur,
    output [5:0] do_pre_state
    );

    assign do_sur = di_cur_state[5];
    assign do_pre_state = {di_cur_state[4:0],di_sur_path[di_cur_state]};

endmodule
