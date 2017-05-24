//% @file MEAN.v
//% @brief Implementation file of mean(MEAN) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-10-04

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//=============================================================================
// Module Declaration

//% Signal Constellation De-Mapping(SCDM) calculate the mean of 10 repeat demapped
//% signal data.
module MEAN(
    input        clk,
    input        rst,
    input        di,
    input        di_vld,
    output  reg  do,
    output  reg  do_vld
    );

//=============================================================================
// Main Body of Code

    reg         wea;
    reg         dina;
    //% save input data into RAM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wea  <= 0;
            dina <= 0;
        end
        else begin
            wea  <= di_vld;
            dina <= di;
        end
    end

    reg  [9:0]  addra;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addra <= 9'b0;
        end
        else begin
            if (wea) begin
                addra <= addra + 1;
            end
            else begin
                addra <= 0;
            end
        end
    end

    reg  [9:0]  input_cnt;
    //% count input data number
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            input_cnt <= 9'd0;
        end
        else begin
            if (wea) begin
                input_cnt <= input_cnt + 1;
            end
            else begin
                input_cnt <= 0;
            end
        end
    end

    reg         out_cnt_en;
    reg  [9:0]  out_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt_en <= 0;
        end
        else begin
            if (input_cnt == 10'd959) begin
                out_cnt_en <= 1'b1;
            end
            else if (out_cnt == 10'd959) begin
                out_cnt_en <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt <= 0;
        end
        else begin
            if (out_cnt_en) begin
                out_cnt <= out_cnt + 1;
            end
        end
    end

    reg  [8:0]  out_cnt1;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt1 <= 9'd0;
        end
        else begin
            if (out_cnt_en) begin
                if (out_cnt1 == 4'd9) begin
                    out_cnt1 <= 0;
                end
                else begin
                    out_cnt1 <= out_cnt1 + 1;
                end
            end
            else begin
                out_cnt1 <= 9'd0;
            end
        end
    end

    reg  [6:0]  out_cnt2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt2 <= 0;
        end
        else begin
            if (out_cnt_en) begin
                if (out_cnt1 == 8) begin
                    out_cnt2 <= out_cnt2 + 1;
                end
            end
            else begin
                out_cnt2 <= 0;
            end
        end
    end

    reg  [9:0]  addrb;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addrb <= 0;
        end
        else begin
            if (out_cnt_en) begin
                if (out_cnt1 == 9) begin
                    addrb <= out_cnt2;
                end
                else begin
                    addrb <= addrb + 96;
                end
            end
        end
    end

    //% read data out from RAM
    wire    doutb;
    reg     doutb_vld;
    reg     out_cnt_en_r1;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            out_cnt_en_r1 <= out_cnt_en;
            doutb_vld <= 0;
        end
        else begin
            out_cnt_en_r1 <= out_cnt_en;
            doutb_vld <= out_cnt_en_r1;
        end
    end

    //--------------------------------------------------------------------------
    // calcualte average

    reg  [3:0]  acc_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            acc_cnt <= 0;
        end
        else begin
            if (doutb_vld) begin
                if (acc_cnt == 9) begin
                    acc_cnt <= 0;
                end
                else begin
                    acc_cnt <= acc_cnt + 1;
                end
            end
            else begin
                acc_cnt <= 0;
            end
        end
    end

    reg  [3:0]  acc;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            acc <= 0;
        end
        else begin
            if (doutb_vld) begin
                if (acc_cnt == 9) begin
                    acc <= 0;
                end
                else begin
                    acc <= acc + doutb;
                end
            end
            else begin
                acc <= 0;
            end
        end
    end

//-----------------------------------------------------------------------------
    // save results into RAM
    reg [6:0] addra1;
    reg wea1;
    reg dina1;
    reg read_en_tmp0;
    reg read_en_tmp1;
    // reg read_en_tmp2;
    reg read_en;
    reg [6:0] read_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addra1 <= 7'b111_1111;
            read_en <= 0;

            read_en_tmp0 <= 1;
            read_en_tmp1 <= 1;
            // read_en_tmp2 <= 1;
        end
        else begin
            if (acc_cnt == 9) begin
                addra1 <= addra1 + 1;
            end
            else begin
                addra1 <= addra1;
            end

            if (addra1 < 95) begin
                read_en <= 0;
            end
            if (addra1 == 95) begin
                addra1 <= 7'b111_1111;
                read_en <= 1;
            end

            if (read_cnt == 95) begin
                read_en_tmp0 <= 0;
                read_en_tmp1 <= read_en_tmp0;
                // read_en_tmp2 <= read_en_tmp1;
                read_en <= read_en_tmp1;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            wea1 <= 0;
            dina1 <= 0;
        end
        else begin
            if (acc_cnt == 9) begin
                if (acc >= 5) begin
                    dina1 <= 1'b1;
                end
                else begin
                    dina1 <= 1'b0;
                end
                wea1 <= 1;
            end
            else begin
                dina1 <= 0;
                wea1 <= 0;
            end
        end
    end

    // read out
    reg [6:0] addrb1;
    wire doutb1;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            read_cnt <= 0;
        end
        else begin
            if (read_en) begin
                if (read_cnt < 95) begin
                    read_cnt <= read_cnt + 1;
                end
                if (read_cnt == 95) begin
                    read_cnt <= read_cnt;
                end
            end
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            addrb1 <= 0;
        end
        else begin
            if (read_en) begin
                addrb1 <= addrb1 + 1;
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
                do <= doutb1;
            end
            else begin
                do <= 0;
            end
        end
    end

    reg do_vld_tmp1;
    reg do_vld_tmp2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            do_vld <= 0;
            do_vld_tmp1 <= 0;
            do_vld_tmp2 <= 0;
        end
        else begin
            if (read_en) begin
                do_vld_tmp1 <= read_en;
                do_vld_tmp2 <= do_vld_tmp1;
                do_vld <= do_vld_tmp2;
            end
            else begin
                do_vld_tmp1 <= 0;
                do_vld_tmp2 <= 0;
                do_vld <= 0;
            end
        end
    end
    
    // always @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         // reset
    //         do <= 0;
    //         do_vld <= 0;
    //     end
    //     else begin
    //         if (acc_cnt == 9) begin
    //             if (acc >= 5) begin
    //                 do <= 1'b1;
    //             end
    //             else begin
    //                 do <= 1'b0;
    //             end
    //             do_vld <= 1;
    //         end
    //         else begin
    //             do <= 0;
    //             do_vld <= 0;
    //         end
    //     end
    // end

    MEAN_RAM U_MEAN_RAM (
        .clka(clk),    // input wire clka
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina(dina),    // input wire [0 : 0] dina

        .clkb(clk),    // input wire clkb
        .addrb(addrb),  // input wire [9 : 0] addrb
        .doutb(doutb)  // output wire [0 : 0] doutb
    );


    OUT_RAM U_OUT_RAM (
      .clka(clk),    // input wire clka
      .wea(wea1),      // input wire [0 : 0] wea
      .addra(addra1),  // input wire [4 : 0] addra
      .dina(dina1),    // input wire [2 : 0] dina
      .clkb(clk),    // input wire clkb
      .addrb(addrb1),  // input wire [4 : 0] addrb
      .doutb(doutb1)  // output wire [2 : 0] doutb
    );

endmodule