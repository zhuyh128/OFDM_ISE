//% @file recv.v
//% @brief Implementation file of Receiver(RECV) module.
//% 
//% @author  Qian Gu
//% @version 1.0
//% @date 2015-06-01

`include "global_define.vh"      //% include global define file
`timescale 1ns / 1ps

//==============================================================================
// Module Declaration
// 
//% @note the input data should not be from TRANS directly, for test, we add
//% @note some zeros before the data from TRANS

module RECV (
    input                  clk,             //% working clock
    input                  rst,             //% reset activ high
    input  signed  [11:0]  di_re,           //% input received data
    input  signed  [11:0]  di_im,           //% input received data

    output                 do_signal,       //% signal decode output(tail biting convolution)
    output                 do_signal_vld,
    output                 do_payload,      //% payload decode output(LDPC)
    output                 do_payload_vld
    );

//==============================================================================
// Main Body of Code

    //--------------------------------------------------------------------------
    // PSU --> CFOE
    wire  signed  [11:0]  PSU2CFOE_data_re;
    wire  signed  [11:0]  PSU2CFOE_data_im;
    wire                  PSU2CFOE_packet_start;

    //--------------------------------------------------------------------------
    // CFOE --> CFOC
    wire  signed  [11:0]  CFOE2C_data_re;
    wire  signed  [11:0]  CFOE2C_data_im;
    wire                  CFOE2C_cs_start;
    wire  signed  [17:0]  CFOE2C_cfo_estimated;
    wire                  CFOE2C_cfo_estimated_vld;

    //--------------------------------------------------------------------------
    // CFOC --> SSYNC
    wire  signed  [11:0]  CFOC2SSYNC_data_re;
    wire  signed  [11:0]  CFOC2SSYNC_data_im;
    wire                  CFOC2SSYNC_data_vld;

    //--------------------------------------------------------------------------
    // SSYNC --> DSEP
    wire  signed  [11:0]  SSYNC2DSEP_data_re;
    wire  signed  [11:0]  SSYNC2DSEP_data_im;
    wire                  SSYNC2DSEP_data_vld;
    wire          [9 :0]  SSYNC2DSEP_max_indx;
    wire                  SSYNC2DSEP_max_indx_vld;

    //--------------------------------------------------------------------------
    // DSEP --> DECP
    wire  signed  [11:0]  DSEP2DECP_sigpld_re;
    wire  signed  [11:0]  DSEP2DECP_sigpld_im;
    wire                  DSEP2DECP_sigpld_vld;

    //--------------------------------------------------------------------------
    // DSEP --> CEST
    wire  signed  [11:0]  DSEP2CEST_preamble_re;
    wire  signed  [11:0]  DSEP2CEST_preamble_im;
    wire                  DSEP2CEST_preamble_vld;

    //--------------------------------------------------------------------------
    // DECP --> SPFFT
    wire  signed  [11:0]  DECP2SPFFT_data_re;
    wire  signed  [11:0]  DECP2SPFFT_data_im;
    wire                  DECP2SPFFT_data_vld;

    //--------------------------------------------------------------------------
    // SPFFT --> CCOM
    wire  signed  [11:0]  SPFFT2CCOM_data_re;
    wire  signed  [11:0]  SPFFT2CCOM_data_im;
    wire                  SPFFT2CCOM_data_vld;

    //--------------------------------------------------------------------------
    // CEST --> CCOM
    wire  signed  [11:0]  CEST2CCOM_H_re;
    wire  signed  [11:0]  CEST2CCOM_H_im;
    wire                  CEST2CCOM_H_vld;

    //--------------------------------------------------------------------------
    // CEST --> PDMOD
    wire  signed  [11:0]  CEST2PDMOD_sigma2;
    wire                  CEST2PDMOD_sigma2_vld;

    //--------------------------------------------------------------------------
    // CCOM --> SPSEP
    wire  signed  [11:0]  CCOM2SPSEP_data_re;
    wire  signed  [11:0]  CCOM2SPSEP_data_im;
    wire                  CCOM2SPSEP_data_vld;

    //--------------------------------------------------------------------------
    // SPSEP --> SDMOD
    wire  signed  [11:0]  SPSEP2SDMOD_data_re;
    wire  signed  [11:0]  SPSEP2SDMOD_data_im;
    wire                  SPSEP2SDMOD_data_vld;

    //--------------------------------------------------------------------------
    // SDMOD --> SCD
    wire                  SDMOD2SCD_data;
    wire                  SDMOD2SCD_data_vld;
    
    //--------------------------------------------------------------------------
    // SPSEP --> PDMOD
    wire  signed  [11:0]  SPSEP2PDMOD_data_re;
    wire  signed  [11:0]  SPSEP2PDMOD_data_im;
    wire                  SPSEP2PDMOD_data_vld;

    //--------------------------------------------------------------------------
    // PDMOD --> PCD(LDPC Channel Decode)
    wire  signed  [7:0]   PDMOD2PCD_data;
    wire                  PDMOD2PCD_data_vld;
    
    reg  signed  [7:0]    DECODE_in;
    //--------------------------------------------------------------------------
    // instantiate sub-module

    PSU U_PSU (
        .clk(clk),        
        .rst(rst),        

        .di_re(di_re),      
        .di_im(di_im),      
        
        .do_re(PSU2CFOE_data_re),      
        .do_im(PSU2CFOE_data_im),      
        .packet_start(PSU2CFOE_packet_start)
    );

    CFOE U_CFOE (
        .clk(clk),
        .rst(rst),

        .di_re(PSU2CFOE_data_re),
        .di_im(PSU2CFOE_data_im),
        .packet_start(PSU2CFOE_packet_start),
        
        .do_re(CFOE2C_data_re),
        .do_im(CFOE2C_data_im),
        .cs_start(CFOE2C_cs_start),
        .cfo_estimated(CFOE2C_cfo_estimated),
        .cfo_estimated_vld(CFOE2C_cfo_estimated_vld)
    );

    CFOC U_CFOC (
        .clk(clk),
        .rst(rst),

        .di_re(CFOE2C_data_re),            
        .di_im(CFOE2C_data_im),            
        .cs_start(CFOE2C_cs_start),         
        .cfo_estimated(CFOE2C_cfo_estimated),    
        .cfo_estimated_vld(CFOE2C_cfo_estimated_vld),
        
        .do_re(CFOC2SSYNC_data_re),           
        .do_im(CFOC2SSYNC_data_im),            
        .do_vld(CFOC2SSYNC_data_vld)           
    );

    SSYNC U_SSYNC (
        .clk(clk),        
        .rst(rst),        

        .di_re(CFOC2SSYNC_data_re),      
        .di_im(CFOC2SSYNC_data_im),      
        .di_vld(CFOC2SSYNC_data_vld), 

        .do_re(SSYNC2DSEP_data_re),      
        .do_im(SSYNC2DSEP_data_im),      
        .do_vld(SSYNC2DSEP_data_vld),     
        .max_indx(SSYNC2DSEP_max_indx),         
        .max_indx_vld(SSYNC2DSEP_max_indx_vld)
    );

    DSEP U_DSEP (
        .clk(clk),            
        .rst(rst),            

        .di_re(SSYNC2DSEP_data_re),          
        .di_im(SSYNC2DSEP_data_im),          
        .di_vld(SSYNC2DSEP_data_vld),         
        .max_indx(SSYNC2DSEP_max_indx),       
        .max_indx_vld(SSYNC2DSEP_max_indx_vld),   

        .do_preamble_re(DSEP2CEST_preamble_re), 
        .do_preamble_im(DSEP2CEST_preamble_im), 
        .do_preamble_vld(DSEP2CEST_preamble_vld),

        .do_sigpld_re(DSEP2DECP_sigpld_re),   
        .do_sigpld_im(DSEP2DECP_sigpld_im),   
        .do_sigpld_vld(DSEP2DECP_sigpld_vld)   
    );

    // branch1: preamble
    CEST U_CEST (
        .clk(clk),            
        .rst(rst),

        .di_re(DSEP2CEST_preamble_re),          
        .di_im(DSEP2CEST_preamble_im),          
        .di_vld(DSEP2CEST_preamble_vld),         

        .H_estimated_re(CEST2CCOM_H_re), 
        .H_estimated_im(CEST2CCOM_H_im), 
        .H_estimated_vld(CEST2CCOM_H_vld),

        .sigma2(CEST2PDMOD_sigma2),         
        .sigma2_vld(CEST2PDMOD_sigma2_vld)
    );

    // branch2: signal & payload
    DECP U_DECP (
        .clk(clk),   
        .rst(rst),   

        .di_re(DSEP2DECP_sigpld_re), 
        .di_im(DSEP2DECP_sigpld_im), 
        .di_vld(DSEP2DECP_sigpld_vld),

        .do_re(DECP2SPFFT_data_re), 
        .do_im(DECP2SPFFT_data_im), 
        .do_vld(DECP2SPFFT_data_vld) 
    );

    SPFFT U_SPFFT (
        .clk(clk),   
        .rst(rst),   

        .di_re(DECP2SPFFT_data_re), 
        .di_im(DECP2SPFFT_data_im), 
        .di_vld(DECP2SPFFT_data_vld),

        .do_re(SPFFT2CCOM_data_re), 
        .do_im(SPFFT2CCOM_data_im), 
        .do_vld(SPFFT2CCOM_data_vld)
    );

    CCOM U_CCOM (
        .clk(clk),
        .rst(rst),

        .din_sp_re(SPFFT2CCOM_data_re),
        .din_sp_im(SPFFT2CCOM_data_im),
        .din_sp_vld(SPFFT2CCOM_data_vld),

        .din_H_re(CEST2CCOM_H_re), 
        .din_H_im(CEST2CCOM_H_im), 
        .din_H_vld(CEST2CCOM_H_vld),

        .dout_re(CCOM2SPSEP_data_re),  
        .dout_im(CCOM2SPSEP_data_im),  
        .dout_vld(CCOM2SPSEP_data_vld)
    );

    SPSEP U_SPSEP (
        .clk(clk),
        .rst(rst),

        .din_re(CCOM2SPSEP_data_re),
        .din_im(CCOM2SPSEP_data_im),
        .din_vld(CCOM2SPSEP_data_vld),

        .dout_signal_re(SPSEP2SDMOD_data_re),
        .dout_signal_im(SPSEP2SDMOD_data_im),
        .dout_signal_vld(SPSEP2SDMOD_data_vld),

        .dout_payload_re(SPSEP2PDMOD_data_re),
        .dout_payload_im(SPSEP2PDMOD_data_im),
        .dout_payload_vld(SPSEP2PDMOD_data_vld)
    );

    SDMOD U_SDMOD (
        .clk(clk),
        .rst(rst),

        .di_re(SPSEP2SDMOD_data_re),
        .di_im(SPSEP2SDMOD_data_im),
        .di_vld(SPSEP2SDMOD_data_vld),
        
        .do(SDMOD2SCD_data),
        .do_vld(SDMOD2SCD_data_vld)
    );


    PDMOD U_PDMOD (
        .clk(clk),
        .rst(rst),

        .di_re(SPSEP2PDMOD_data_re),
        .di_im(SPSEP2PDMOD_data_im),
        .di_vld(SPSEP2PDMOD_data_vld),
        .di_sigma2(CEST2PDMOD_sigma2),
        .di_sigma2_vld(CEST2PDMOD_sigma2_vld),
        
        .do_llr(PDMOD2PCD_data),
        .do_llr_vld(PDMOD2PCD_data_vld)
    );

    // the llr are delayed 1 clock period to fit the input of PCD
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            DECODE_in <= 0;
        end
        else begin
            if (PDMOD2PCD_data_vld) begin
                DECODE_in <= PDMOD2PCD_data;
            end
            else begin
                DECODE_in <= 0;
            end
        end
    end

    SCD U_SCD(
        .clk(clk),
        .rst(rst),

        .di(SDMOD2SCD_data),
        .di_vld(SDMOD2SCD_data_vld),
        
        .do(do_signal),
        .do_vld(do_signal_vld)
        );

    PCD U_PCD(
        .reset(rst),
        .clk_in(clk),
        
        .symbol_din(DECODE_in),
        .frame_start(PDMOD2PCD_data_vld),

        .ldpc_dout(do_payload),
        .frame_finish(do_payload_vld)
        );

endmodule