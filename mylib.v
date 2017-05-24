//% @file mylib.v
//% @brief Implementation file of common library, usual modules.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-23
// 

`timescale 1ns / 1ps

//=============================================================================
// module Declaration

module DLY1 #(parameter WIDTH = 8)
    (
     input                       clk,
     input                       rst,
     input        [WIDTH-1 : 0]  din,
     output  reg  [WIDTH-1 : 0]  dout
    );

//=============================================================================
// Main Body of Code

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            dout <= 0;
        end
        else begin
            dout <= din;
        end
    end

endmodule


//=============================================================================
// module Declaration
/*
module DLY2 #(parameter WIDTH = 8)
    (
     input                       clk,
     input                       rst,
     input        [WIDTH-1 : 0]  din,
     output  reg  [WIDTH-1 : 0]  dout
    );

//=============================================================================
// Main Body of Code

    reg     [WIDTH-1 : 0]  data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data <= 0;
            dout <= 0;
        end
        else begin
            data <= din;
            dout <= data;
        end
    end

endmodule
*/
//=============================================================================
// module Declaration

module DLY3 #(parameter WIDTH = 8)
    (
     input                       clk,
     input                       rst,
     input        [WIDTH-1 : 0]  din,
     output  reg  [WIDTH-1 : 0]  dout
    );

//=============================================================================
// Main Body of Code

    reg     [WIDTH-1 : 0]  data1;
    reg     [WIDTH-1 : 0]  data2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data1 <= 0;
            data2 <= 0;
            dout  <= 0;
        end
        else begin
            data1 <= din;
            data2 <= data1;
            dout  <= data2;
        end
    end

endmodule

//=============================================================================
// module Declaration
/*
module DLY4 #(parameter WIDTH = 8)
    (
     input                       clk,
     input                       rst,
     input        [WIDTH-1 : 0]  din,
     output  reg  [WIDTH-1 : 0]  dout
    );

//=============================================================================
// Main Body of Code

    reg     [WIDTH-1 : 0]  data1;
    reg     [WIDTH-1 : 0]  data2;
    reg     [WIDTH-1 : 0]  data3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            data1 <= 0;
            data2 <= 0;
            data3 <= 0;
            dout  <= 0;
        end
        else begin
            data1 <= din;
            data2 <= data1;
            data3 <= data2;
            dout  <= data3;
        end
    end

endmodule
*/