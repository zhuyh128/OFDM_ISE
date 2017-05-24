//% @file global_define.v
//% @brief Global defininations for project.
//% 
//% @author Qian Gu
//% @version 1.0
//% @date 2015-04-22


`ifndef GLOBAL_DEFINE_H
`define GLOBAL_DEFINE_H
    
    //--------------------------------------------------------------------------
    // common define
    `define    N          512    //% number of total sub-carriers in one OFDM symbol
    `define    SPACE_NUM  32     //% white space in one OFDM symbol
    `define    CP_LEN     9'd32  //% length of cyclic preifx, DO NOT change the width = 9
    `define    PRB_NUM    8      //% number of preamble symbols
    `define    MAX_NUM    10     //% max number of signal + payload symbols
	 
	 `define		NF			  3		//%number of frame			Modified by baiyf			

    //--------------------------------------------------------------------------
    // for simlulation
    `define    CLK_PERIOD    10  //% clock period for simulation

    //--------------------------------------------------------------------------
    // definiation for SSG
    `define    K    6       //% (3, 1, 6) tail-biting convolution in LTE
    `define    PCER 4'd2    //% payload channel encode rate = 1/2
    `define    MODM 4'd4    //% modulation type for payload, 4 = 16QAM

    //-------------------------------------------------------------------------
    // for signal channel decode
    `define   DEPTH    32
    `define   SIGNAL_CODED_LEN    96


`endif
