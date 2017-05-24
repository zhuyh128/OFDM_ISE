//% @file plg.v
//% @brief Implementation file of Payload Segment Generator(PLG) module. 
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-04-22

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration

//% Payload Segment Generator(PLG) convert the parallel input(PSDU) to serial 
//% output using a RAM.
//% 
//% **Timing:**
//% 
//% 1. receive data from MAC layer, write it into RAM (parallel, 8 bits).
//% 2. when finish writing, start to read from RAM (serial, 1 bits).
//% 
//% @note The first data is written into addra = 1, so read address start from 8.
//
//% @note need to fix when LDPC is finished !!!
module PLG (
    input             clk_s,      //% output data(serial) clock
    input             clk_p,      //% input data(parallel, 8 bits) clock
    input             rst,        //% asynchronous reset, active high
    input  [7 : 0]    di,         //% original payload data input(parallel)
    input  [14: 0]    di_num,     //% number of input data
    input             di_vld,     //% input data valid
    
    output            do,         //% original payload data output(serial)
    output  reg       do_vld      //% output data valid
    );

//==============================================================================
// Local Parameter Declaration

    localparam  DAT_WIDTH = 8;   //% local tmp data width = input data width

//==============================================================================
// Mian Body of Code

    //--------------------------------------------------------------------------
    // generate the data into RAM

    reg  [DAT_WIDTH-1 : 0]    data;   //% tmp to delay input data 1 clock cycle
    //% delay input 1 clock cycle 
    always @(posedge clk_p) begin
        data <= di;
    end

    //--------------------------------------------------------------------------
    // RAM write

    wire        ena = 1;        //% port A is always enable
    reg         wea;            //% port A write enable
    //% write data into RAM
    always @(posedge clk_p or posedge rst) begin
        if (rst) begin
            // reset
            wea <= 0;
        end
        else begin
            if (di_vld) begin
                wea <= 1;
            end
            else begin
                wea <= 0;
            end
        end
    end

    reg    [11:0]    addra;     //% port A write address
    //% generate writing address
    always @(posedge clk_p or posedge rst) begin
        if (rst) begin
            // reset
            addra <= 0;
        end
        else begin
            if (di_vld) begin
                addra <= addra + 1;  // the first data is write into addra = 1
            end
            else begin
                addra <= 0;          // return addra to 0 for next frame
            end
        end
    end

    //--------------------------------------------------------------------------
    // RAM read

    wire            wr_done;    //% data writen finish flag
    reg     [1:0]   trig;       //% reg used to detect the negedge of di_vld
    //% detect the negedge of di_vld
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            trig <= 2'b0;
        end
        else begin
            trig <= {trig[0], di_vld};
        end
    end
    assign wr_done = (trig[1:0] == 2'b10);

    reg     [14:0]  num_di_bits;        //% number of all input bits
    //% calculate the number of all input bits
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            num_di_bits <= 0;
        end
        else begin
            if (di_vld) begin
                num_di_bits <= di_num << 3; // n data * 8 bits/data = 8*n
            end
        end
    end

    // reg     [4 :0]   num_padding_bits;      //% for test, N = 32 --> [4:0]
    reg     [8 :0]   num_padding_bits;      //% number of all padding btis
    reg     [14:0]   num_padding_tmp;       //% local tmp for num_pdding
    //% calculate the number of all padding bits
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            num_padding_tmp  <= 0;
            num_padding_bits <= 0;
        end
        else begin
            if (di_vld) begin
                num_padding_tmp  <= di_num << 3;
                // num_padding_bits <= ~num_padding_tmp[4:0] + 1; // for test
                // number of padding = N - module = 2's complement
                num_padding_bits <= ~num_padding_tmp[8:0] + 1;  
            end
        end
    end

    reg     [14:0]  rd_cnt_max; //% counter max
    //% calculate the number of total bits{origin + padding}
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            rd_cnt_max <= 0;
        end
        else begin
            if (di_vld) begin
                rd_cnt_max <= num_di_bits + num_padding_bits;
            end
        end
    end

    reg     [14:0]  rd_cnt;     //% ouptut data counter
    //% count the number of output data
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            rd_cnt <= 0;
        end
        else begin
            if (rd_cnt == (rd_cnt_max+2)) begin
                rd_cnt <= 0;
            end
            else if (enb) begin
                rd_cnt <= rd_cnt + 1;
            end
            else begin
                rd_cnt <= 0;
            end
        end
    end

    reg              enb;       //% port B enabled
    //% enable port B when finish writing
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            enb <= 0;
        end
        else begin
            if (wr_done) begin
                enb <= 1;
            end
            else if (rd_cnt == (rd_cnt_max+2)) begin    // watch out!
                enb <= 0;
            end
        end
    end

    reg    [14:0]    addrb1;    //% address for origin bits
    //% generate reading address1 for origin bits
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            addrb1 <= 8;     // because writing from addra = 1, so read from addrb = 8
        end
        else begin
            if (enb) begin
                addrb1 <= addrb1 + 1;
            end
            else begin
                addrb1 <= 8;
            end
        end
    end

    reg    [14:0]    addrb2;    //% address for padding btis
    //% generate reading address2 for padding btis
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            addrb2 <= 8;
        end
        else begin
            if (enb) begin
                if (rd_cnt > num_di_bits-1) begin
                    addrb2 <= addrb2 + 1;
                end
            end
            else begin
                addrb2 <= 8;
            end
        end
    end

    reg    [14:0]    addrb;     //% port B read address
    //% read address = address1 or address2
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            addrb <= 8;
        end
        else begin
            if (enb) begin
                if (rd_cnt < num_di_bits) addrb <= addrb1;
                else                      addrb <= addrb2;
            end
            else begin
                addrb <= 8;
            end
        end
    end

    //% generate output data valid (do_vld)
    always @(posedge clk_s or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
        end
        else begin
            if (rd_cnt >= 2 && rd_cnt <= rd_cnt_max+1)
                do_vld <= 1;
            else
                do_vld <= 0;
        end
    end

    //-----------------------------------------------
    //% instantiate a RAM IP core
    PLG_RAM U_PLG_RAM (
        .clka(clk_p),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [11 : 0] addra
        .dina(data),    // input wire [7 : 0] dina
        .clkb(clk_s),    // input wire clkb
        .enb(enb),      // input wire enb
        .addrb(addrb),  // input wire [14 : 0] addrb
        .doutb(do)  // output wire [0 : 0] doutb
    );

endmodule