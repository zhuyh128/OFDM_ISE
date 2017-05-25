////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: NFU_MULT_IM.v
// /___/   /\     Timestamp: Wed May 24 18:56:05 2017
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/study/projects/ise-projects/OFDM/ipcore_dir/tmp/_cg/NFU_MULT_IM.ngc E:/study/projects/ise-projects/OFDM/ipcore_dir/tmp/_cg/NFU_MULT_IM.v 
// Device	: 7k160tffg676-1
// Input file	: E:/study/projects/ise-projects/OFDM/ipcore_dir/tmp/_cg/NFU_MULT_IM.ngc
// Output file	: E:/study/projects/ise-projects/OFDM/ipcore_dir/tmp/_cg/NFU_MULT_IM.v
// # of Modules	: 1
// Design Name	: NFU_MULT_IM
// Xilinx        : C:\Xilinx\14.7\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module NFU_MULT_IM (
  clk, sclr, a, p
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input sclr;
  input [11 : 0] a;
  output [23 : 0] p;
  
  // synthesis translate_off
  
  wire \blk00000001/sig0000009b ;
  wire \blk00000001/sig0000009a ;
  wire \blk00000001/sig00000099 ;
  wire \blk00000001/sig00000098 ;
  wire \blk00000001/sig00000097 ;
  wire \blk00000001/sig00000096 ;
  wire \blk00000001/sig00000095 ;
  wire \blk00000001/sig00000094 ;
  wire \blk00000001/sig00000093 ;
  wire \blk00000001/sig00000092 ;
  wire \blk00000001/sig00000091 ;
  wire \blk00000001/sig00000090 ;
  wire \blk00000001/sig0000008f ;
  wire \blk00000001/sig0000008e ;
  wire \blk00000001/sig0000008d ;
  wire \blk00000001/sig0000008c ;
  wire \blk00000001/sig0000008b ;
  wire \blk00000001/sig0000008a ;
  wire \blk00000001/sig00000089 ;
  wire \blk00000001/sig00000088 ;
  wire \blk00000001/sig00000087 ;
  wire \blk00000001/sig00000086 ;
  wire \blk00000001/sig00000085 ;
  wire \blk00000001/sig00000084 ;
  wire \blk00000001/sig00000083 ;
  wire \blk00000001/sig00000082 ;
  wire \blk00000001/sig00000081 ;
  wire \blk00000001/sig00000080 ;
  wire \blk00000001/sig0000007f ;
  wire \blk00000001/sig0000007e ;
  wire \blk00000001/sig0000007d ;
  wire \blk00000001/sig0000007c ;
  wire \blk00000001/sig0000007b ;
  wire \blk00000001/sig0000007a ;
  wire \blk00000001/sig00000079 ;
  wire \blk00000001/sig00000078 ;
  wire \blk00000001/sig00000077 ;
  wire \blk00000001/sig00000076 ;
  wire \blk00000001/sig00000075 ;
  wire \blk00000001/sig00000074 ;
  wire \blk00000001/sig00000073 ;
  wire \blk00000001/sig00000072 ;
  wire \blk00000001/sig00000071 ;
  wire \blk00000001/sig00000070 ;
  wire \blk00000001/sig0000006f ;
  wire \blk00000001/sig0000006e ;
  wire \blk00000001/sig0000006d ;
  wire \blk00000001/sig0000006c ;
  wire \blk00000001/sig0000006b ;
  wire \blk00000001/sig0000006a ;
  wire \blk00000001/sig00000069 ;
  wire \blk00000001/sig00000068 ;
  wire \blk00000001/sig00000067 ;
  wire \blk00000001/sig00000066 ;
  wire \blk00000001/sig00000065 ;
  wire \blk00000001/sig00000064 ;
  wire \blk00000001/sig00000063 ;
  wire \blk00000001/sig00000062 ;
  wire \blk00000001/sig00000061 ;
  wire \blk00000001/sig00000060 ;
  wire \blk00000001/sig0000005f ;
  wire \blk00000001/sig0000005e ;
  wire \blk00000001/sig0000005d ;
  wire \blk00000001/sig0000005c ;
  wire \blk00000001/sig0000005b ;
  wire \blk00000001/sig0000005a ;
  wire \blk00000001/sig00000059 ;
  wire \blk00000001/sig00000058 ;
  wire \blk00000001/sig00000057 ;
  wire \blk00000001/sig00000056 ;
  wire \blk00000001/sig00000055 ;
  wire \blk00000001/sig00000054 ;
  wire \blk00000001/sig00000053 ;
  wire \blk00000001/sig00000052 ;
  wire \blk00000001/sig00000051 ;
  wire \blk00000001/sig00000050 ;
  wire \blk00000001/sig0000004f ;
  wire \blk00000001/sig0000004e ;
  wire \blk00000001/sig0000004d ;
  wire \blk00000001/sig0000004c ;
  wire \blk00000001/sig0000004b ;
  wire \blk00000001/sig0000004a ;
  wire \blk00000001/sig00000049 ;
  wire \blk00000001/sig00000048 ;
  wire \blk00000001/sig00000047 ;
  wire \blk00000001/sig00000046 ;
  wire \blk00000001/sig00000045 ;
  wire \blk00000001/sig00000044 ;
  wire \blk00000001/sig00000043 ;
  wire \blk00000001/sig00000042 ;
  wire \blk00000001/sig00000041 ;
  wire \blk00000001/sig00000040 ;
  wire \blk00000001/sig0000003f ;
  wire \blk00000001/sig0000003e ;
  wire \blk00000001/sig0000003d ;
  wire \blk00000001/sig0000003c ;
  wire \blk00000001/sig0000003b ;
  wire \blk00000001/sig0000003a ;
  wire \blk00000001/sig00000039 ;
  wire \blk00000001/sig00000038 ;
  wire \blk00000001/sig00000037 ;
  wire \blk00000001/sig00000036 ;
  wire \blk00000001/sig00000035 ;
  wire \blk00000001/sig00000034 ;
  wire \blk00000001/sig00000033 ;
  wire \blk00000001/sig00000032 ;
  wire \blk00000001/sig00000031 ;
  wire \blk00000001/sig00000030 ;
  wire \blk00000001/sig0000002f ;
  wire \blk00000001/sig0000002e ;
  wire \blk00000001/sig0000002d ;
  wire \blk00000001/sig0000002c ;
  wire \blk00000001/sig0000002b ;
  wire \blk00000001/sig0000002a ;
  wire \blk00000001/sig00000029 ;
  wire \blk00000001/sig00000028 ;
  wire \blk00000001/sig00000027 ;
  wire [0 : 0] NlwRenamedSig_OI_p;
  assign
    p[0] = NlwRenamedSig_OI_p[0];
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000008e  (
    .I0(\blk00000001/sig00000032 ),
    .O(\blk00000001/sig0000009b )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000008d  (
    .I0(\blk00000001/sig00000033 ),
    .O(\blk00000001/sig0000009a )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000008c  (
    .I0(\blk00000001/sig00000034 ),
    .O(\blk00000001/sig00000099 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000008b  (
    .I0(\blk00000001/sig00000035 ),
    .O(\blk00000001/sig00000098 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \blk00000001/blk0000008a  (
    .I0(\blk00000001/sig00000036 ),
    .O(\blk00000001/sig00000097 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000089  (
    .C(clk),
    .D(\blk00000001/sig00000038 ),
    .R(sclr),
    .Q(p[1])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000088  (
    .C(clk),
    .D(\blk00000001/sig00000039 ),
    .R(sclr),
    .Q(p[2])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000087  (
    .C(clk),
    .D(\blk00000001/sig0000003a ),
    .R(sclr),
    .Q(p[3])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000086  (
    .C(clk),
    .D(\blk00000001/sig0000003b ),
    .R(sclr),
    .Q(p[4])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000085  (
    .C(clk),
    .D(\blk00000001/sig0000003c ),
    .R(sclr),
    .Q(p[5])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000084  (
    .C(clk),
    .D(\blk00000001/sig0000003d ),
    .R(sclr),
    .Q(p[6])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000083  (
    .C(clk),
    .D(\blk00000001/sig00000086 ),
    .R(sclr),
    .Q(p[7])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000082  (
    .C(clk),
    .D(\blk00000001/sig00000087 ),
    .R(sclr),
    .Q(p[8])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000081  (
    .C(clk),
    .D(\blk00000001/sig00000088 ),
    .R(sclr),
    .Q(p[9])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000080  (
    .C(clk),
    .D(\blk00000001/sig00000089 ),
    .R(sclr),
    .Q(p[10])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007f  (
    .C(clk),
    .D(\blk00000001/sig0000008a ),
    .R(sclr),
    .Q(p[11])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007e  (
    .C(clk),
    .D(\blk00000001/sig0000008b ),
    .R(sclr),
    .Q(p[12])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007d  (
    .C(clk),
    .D(\blk00000001/sig0000008c ),
    .R(sclr),
    .Q(p[13])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007c  (
    .C(clk),
    .D(\blk00000001/sig0000008d ),
    .R(sclr),
    .Q(p[14])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007b  (
    .C(clk),
    .D(\blk00000001/sig0000008e ),
    .R(sclr),
    .Q(p[15])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000007a  (
    .C(clk),
    .D(\blk00000001/sig0000008f ),
    .R(sclr),
    .Q(p[16])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000079  (
    .C(clk),
    .D(\blk00000001/sig00000090 ),
    .R(sclr),
    .Q(p[17])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000078  (
    .C(clk),
    .D(\blk00000001/sig00000091 ),
    .R(sclr),
    .Q(p[18])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000077  (
    .C(clk),
    .D(\blk00000001/sig00000092 ),
    .R(sclr),
    .Q(p[19])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000076  (
    .C(clk),
    .D(\blk00000001/sig00000093 ),
    .R(sclr),
    .Q(p[20])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000075  (
    .C(clk),
    .D(\blk00000001/sig00000094 ),
    .R(sclr),
    .Q(p[21])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000074  (
    .C(clk),
    .D(\blk00000001/sig00000095 ),
    .R(sclr),
    .Q(p[22])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000073  (
    .C(clk),
    .D(\blk00000001/sig00000096 ),
    .R(sclr),
    .Q(p[23])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000072  (
    .I0(\blk00000001/sig0000003e ),
    .I1(\blk00000001/sig00000027 ),
    .O(\blk00000001/sig00000085 )
  );
  MUXCY   \blk00000001/blk00000071  (
    .CI(NlwRenamedSig_OI_p[0]),
    .DI(\blk00000001/sig0000003e ),
    .S(\blk00000001/sig00000085 ),
    .O(\blk00000001/sig00000084 )
  );
  XORCY   \blk00000001/blk00000070  (
    .CI(NlwRenamedSig_OI_p[0]),
    .LI(\blk00000001/sig00000085 ),
    .O(\blk00000001/sig00000086 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000006f  (
    .I0(\blk00000001/sig0000003f ),
    .I1(\blk00000001/sig00000028 ),
    .O(\blk00000001/sig00000083 )
  );
  MUXCY   \blk00000001/blk0000006e  (
    .CI(\blk00000001/sig00000084 ),
    .DI(\blk00000001/sig0000003f ),
    .S(\blk00000001/sig00000083 ),
    .O(\blk00000001/sig00000082 )
  );
  XORCY   \blk00000001/blk0000006d  (
    .CI(\blk00000001/sig00000084 ),
    .LI(\blk00000001/sig00000083 ),
    .O(\blk00000001/sig00000087 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000006c  (
    .I0(\blk00000001/sig00000040 ),
    .I1(\blk00000001/sig00000029 ),
    .O(\blk00000001/sig00000081 )
  );
  MUXCY   \blk00000001/blk0000006b  (
    .CI(\blk00000001/sig00000082 ),
    .DI(\blk00000001/sig00000040 ),
    .S(\blk00000001/sig00000081 ),
    .O(\blk00000001/sig00000080 )
  );
  XORCY   \blk00000001/blk0000006a  (
    .CI(\blk00000001/sig00000082 ),
    .LI(\blk00000001/sig00000081 ),
    .O(\blk00000001/sig00000088 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000069  (
    .I0(\blk00000001/sig00000041 ),
    .I1(\blk00000001/sig0000002a ),
    .O(\blk00000001/sig0000007f )
  );
  MUXCY   \blk00000001/blk00000068  (
    .CI(\blk00000001/sig00000080 ),
    .DI(\blk00000001/sig00000041 ),
    .S(\blk00000001/sig0000007f ),
    .O(\blk00000001/sig0000007e )
  );
  XORCY   \blk00000001/blk00000067  (
    .CI(\blk00000001/sig00000080 ),
    .LI(\blk00000001/sig0000007f ),
    .O(\blk00000001/sig00000089 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000066  (
    .I0(\blk00000001/sig00000042 ),
    .I1(\blk00000001/sig0000002b ),
    .O(\blk00000001/sig0000007d )
  );
  MUXCY   \blk00000001/blk00000065  (
    .CI(\blk00000001/sig0000007e ),
    .DI(\blk00000001/sig00000042 ),
    .S(\blk00000001/sig0000007d ),
    .O(\blk00000001/sig0000007c )
  );
  XORCY   \blk00000001/blk00000064  (
    .CI(\blk00000001/sig0000007e ),
    .LI(\blk00000001/sig0000007d ),
    .O(\blk00000001/sig0000008a )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000063  (
    .I0(\blk00000001/sig00000043 ),
    .I1(\blk00000001/sig0000002c ),
    .O(\blk00000001/sig0000007b )
  );
  MUXCY   \blk00000001/blk00000062  (
    .CI(\blk00000001/sig0000007c ),
    .DI(\blk00000001/sig00000043 ),
    .S(\blk00000001/sig0000007b ),
    .O(\blk00000001/sig0000007a )
  );
  XORCY   \blk00000001/blk00000061  (
    .CI(\blk00000001/sig0000007c ),
    .LI(\blk00000001/sig0000007b ),
    .O(\blk00000001/sig0000008b )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000060  (
    .I0(\blk00000001/sig00000044 ),
    .I1(\blk00000001/sig0000002d ),
    .O(\blk00000001/sig00000079 )
  );
  MUXCY   \blk00000001/blk0000005f  (
    .CI(\blk00000001/sig0000007a ),
    .DI(\blk00000001/sig00000044 ),
    .S(\blk00000001/sig00000079 ),
    .O(\blk00000001/sig00000078 )
  );
  XORCY   \blk00000001/blk0000005e  (
    .CI(\blk00000001/sig0000007a ),
    .LI(\blk00000001/sig00000079 ),
    .O(\blk00000001/sig0000008c )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000005d  (
    .I0(\blk00000001/sig00000045 ),
    .I1(\blk00000001/sig0000002e ),
    .O(\blk00000001/sig00000077 )
  );
  MUXCY   \blk00000001/blk0000005c  (
    .CI(\blk00000001/sig00000078 ),
    .DI(\blk00000001/sig00000045 ),
    .S(\blk00000001/sig00000077 ),
    .O(\blk00000001/sig00000076 )
  );
  XORCY   \blk00000001/blk0000005b  (
    .CI(\blk00000001/sig00000078 ),
    .LI(\blk00000001/sig00000077 ),
    .O(\blk00000001/sig0000008d )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk0000005a  (
    .I0(\blk00000001/sig00000046 ),
    .I1(\blk00000001/sig0000002f ),
    .O(\blk00000001/sig00000075 )
  );
  MUXCY   \blk00000001/blk00000059  (
    .CI(\blk00000001/sig00000076 ),
    .DI(\blk00000001/sig00000046 ),
    .S(\blk00000001/sig00000075 ),
    .O(\blk00000001/sig00000074 )
  );
  XORCY   \blk00000001/blk00000058  (
    .CI(\blk00000001/sig00000076 ),
    .LI(\blk00000001/sig00000075 ),
    .O(\blk00000001/sig0000008e )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000057  (
    .I0(\blk00000001/sig00000047 ),
    .I1(\blk00000001/sig00000030 ),
    .O(\blk00000001/sig00000073 )
  );
  MUXCY   \blk00000001/blk00000056  (
    .CI(\blk00000001/sig00000074 ),
    .DI(\blk00000001/sig00000047 ),
    .S(\blk00000001/sig00000073 ),
    .O(\blk00000001/sig00000072 )
  );
  XORCY   \blk00000001/blk00000055  (
    .CI(\blk00000001/sig00000074 ),
    .LI(\blk00000001/sig00000073 ),
    .O(\blk00000001/sig0000008f )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \blk00000001/blk00000054  (
    .I0(\blk00000001/sig00000048 ),
    .I1(\blk00000001/sig00000031 ),
    .O(\blk00000001/sig00000071 )
  );
  MUXCY   \blk00000001/blk00000053  (
    .CI(\blk00000001/sig00000072 ),
    .DI(\blk00000001/sig00000048 ),
    .S(\blk00000001/sig00000071 ),
    .O(\blk00000001/sig00000070 )
  );
  XORCY   \blk00000001/blk00000052  (
    .CI(\blk00000001/sig00000072 ),
    .LI(\blk00000001/sig00000071 ),
    .O(\blk00000001/sig00000090 )
  );
  MUXCY   \blk00000001/blk00000051  (
    .CI(\blk00000001/sig00000070 ),
    .DI(NlwRenamedSig_OI_p[0]),
    .S(\blk00000001/sig0000009b ),
    .O(\blk00000001/sig0000006f )
  );
  XORCY   \blk00000001/blk00000050  (
    .CI(\blk00000001/sig00000070 ),
    .LI(\blk00000001/sig0000009b ),
    .O(\blk00000001/sig00000091 )
  );
  MUXCY   \blk00000001/blk0000004f  (
    .CI(\blk00000001/sig0000006f ),
    .DI(NlwRenamedSig_OI_p[0]),
    .S(\blk00000001/sig0000009a ),
    .O(\blk00000001/sig0000006e )
  );
  XORCY   \blk00000001/blk0000004e  (
    .CI(\blk00000001/sig0000006f ),
    .LI(\blk00000001/sig0000009a ),
    .O(\blk00000001/sig00000092 )
  );
  MUXCY   \blk00000001/blk0000004d  (
    .CI(\blk00000001/sig0000006e ),
    .DI(NlwRenamedSig_OI_p[0]),
    .S(\blk00000001/sig00000099 ),
    .O(\blk00000001/sig0000006d )
  );
  XORCY   \blk00000001/blk0000004c  (
    .CI(\blk00000001/sig0000006e ),
    .LI(\blk00000001/sig00000099 ),
    .O(\blk00000001/sig00000093 )
  );
  MUXCY   \blk00000001/blk0000004b  (
    .CI(\blk00000001/sig0000006d ),
    .DI(NlwRenamedSig_OI_p[0]),
    .S(\blk00000001/sig00000098 ),
    .O(\blk00000001/sig0000006c )
  );
  XORCY   \blk00000001/blk0000004a  (
    .CI(\blk00000001/sig0000006d ),
    .LI(\blk00000001/sig00000098 ),
    .O(\blk00000001/sig00000094 )
  );
  MUXCY   \blk00000001/blk00000049  (
    .CI(\blk00000001/sig0000006c ),
    .DI(NlwRenamedSig_OI_p[0]),
    .S(\blk00000001/sig00000097 ),
    .O(\blk00000001/sig0000006b )
  );
  XORCY   \blk00000001/blk00000048  (
    .CI(\blk00000001/sig0000006c ),
    .LI(\blk00000001/sig00000097 ),
    .O(\blk00000001/sig00000095 )
  );
  XORCY   \blk00000001/blk00000047  (
    .CI(\blk00000001/sig0000006b ),
    .LI(\blk00000001/sig00000037 ),
    .O(\blk00000001/sig00000096 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000046  (
    .C(clk),
    .D(\blk00000001/sig0000005a ),
    .R(sclr),
    .Q(\blk00000001/sig00000027 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000045  (
    .C(clk),
    .D(\blk00000001/sig0000005b ),
    .R(sclr),
    .Q(\blk00000001/sig00000028 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000044  (
    .C(clk),
    .D(\blk00000001/sig0000005c ),
    .R(sclr),
    .Q(\blk00000001/sig00000029 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000043  (
    .C(clk),
    .D(\blk00000001/sig0000005d ),
    .R(sclr),
    .Q(\blk00000001/sig0000002a )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000042  (
    .C(clk),
    .D(\blk00000001/sig0000005e ),
    .R(sclr),
    .Q(\blk00000001/sig0000002b )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000041  (
    .C(clk),
    .D(\blk00000001/sig0000005f ),
    .R(sclr),
    .Q(\blk00000001/sig0000002c )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000040  (
    .C(clk),
    .D(\blk00000001/sig00000060 ),
    .R(sclr),
    .Q(\blk00000001/sig0000002d )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003f  (
    .C(clk),
    .D(\blk00000001/sig00000061 ),
    .R(sclr),
    .Q(\blk00000001/sig0000002e )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003e  (
    .C(clk),
    .D(\blk00000001/sig00000062 ),
    .R(sclr),
    .Q(\blk00000001/sig0000002f )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003d  (
    .C(clk),
    .D(\blk00000001/sig00000063 ),
    .R(sclr),
    .Q(\blk00000001/sig00000030 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003c  (
    .C(clk),
    .D(\blk00000001/sig00000064 ),
    .R(sclr),
    .Q(\blk00000001/sig00000031 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003b  (
    .C(clk),
    .D(\blk00000001/sig00000065 ),
    .R(sclr),
    .Q(\blk00000001/sig00000032 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000003a  (
    .C(clk),
    .D(\blk00000001/sig00000066 ),
    .R(sclr),
    .Q(\blk00000001/sig00000033 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000039  (
    .C(clk),
    .D(\blk00000001/sig00000067 ),
    .R(sclr),
    .Q(\blk00000001/sig00000034 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000038  (
    .C(clk),
    .D(\blk00000001/sig00000068 ),
    .R(sclr),
    .Q(\blk00000001/sig00000035 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000037  (
    .C(clk),
    .D(\blk00000001/sig00000069 ),
    .R(sclr),
    .Q(\blk00000001/sig00000036 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000036  (
    .C(clk),
    .D(\blk00000001/sig0000006a ),
    .R(sclr),
    .Q(\blk00000001/sig00000037 )
  );
  RAM64X1S #(
    .INIT ( 64'hB4B4B4B4B4B4B4B4 ))
  \blk00000001/blk00000035  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005c )
  );
  RAM64X1S #(
    .INIT ( 64'hAAAAAAAAAAAAAAAA ))
  \blk00000001/blk00000034  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005a )
  );
  RAM64X1S #(
    .INIT ( 64'h6666666666666666 ))
  \blk00000001/blk00000033  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005b )
  );
  RAM64X1S #(
    .INIT ( 64'hC738C738C738C738 ))
  \blk00000001/blk00000032  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005d )
  );
  RAM64X1S #(
    .INIT ( 64'h5295AD6A5295AD6A ))
  \blk00000001/blk00000031  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005e )
  );
  RAM64X1S #(
    .INIT ( 64'h9B26C9B364D9364C ))
  \blk00000001/blk00000030  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000005f )
  );
  RAM64X1S #(
    .INIT ( 64'h496DA4962DB492DA ))
  \blk00000001/blk0000002f  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000060 )
  );
  RAM64X1S #(
    .INIT ( 64'h924936DB4926DB6C ))
  \blk00000001/blk0000002e  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000061 )
  );
  RAM64X1S #(
    .INIT ( 64'hE38E38E371C71C70 ))
  \blk00000001/blk0000002d  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000062 )
  );
  RAM64X1S #(
    .INIT ( 64'h56A56A562B52B52A ))
  \blk00000001/blk0000002c  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000063 )
  );
  RAM64X1S #(
    .INIT ( 64'h319CE631E7318CE6 ))
  \blk00000001/blk0000002b  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000064 )
  );
  RAM64X1S #(
    .INIT ( 64'hA5294B5A4A5AD6B4 ))
  \blk00000001/blk0000002a  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000065 )
  );
  RAM64X1S #(
    .INIT ( 64'hC6318C63739CE738 ))
  \blk00000001/blk00000029  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000066 )
  );
  RAM64X1S #(
    .INIT ( 64'hF83E0F837C1F07C0 ))
  \blk00000001/blk00000028  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000067 )
  );
  RAM64X1S #(
    .INIT ( 64'hFFC00FFC801FF800 ))
  \blk00000001/blk00000027  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000068 )
  );
  RAM64X1S #(
    .INIT ( 64'hFFFFF000FFE00000 ))
  \blk00000001/blk00000026  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000069 )
  );
  RAM64X1S #(
    .INIT ( 64'hFFFFFFFF00000000 ))
  \blk00000001/blk00000025  (
    .A0(a[6]),
    .A1(a[7]),
    .A2(a[8]),
    .A3(a[9]),
    .A4(a[10]),
    .A5(a[11]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000006a )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000024  (
    .C(clk),
    .D(\blk00000001/sig00000049 ),
    .R(sclr),
    .Q(\blk00000001/sig00000038 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000023  (
    .C(clk),
    .D(\blk00000001/sig0000004a ),
    .R(sclr),
    .Q(\blk00000001/sig00000039 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000022  (
    .C(clk),
    .D(\blk00000001/sig0000004b ),
    .R(sclr),
    .Q(\blk00000001/sig0000003a )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000021  (
    .C(clk),
    .D(\blk00000001/sig0000004c ),
    .R(sclr),
    .Q(\blk00000001/sig0000003b )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000020  (
    .C(clk),
    .D(\blk00000001/sig0000004d ),
    .R(sclr),
    .Q(\blk00000001/sig0000003c )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001f  (
    .C(clk),
    .D(\blk00000001/sig0000004e ),
    .R(sclr),
    .Q(\blk00000001/sig0000003d )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001e  (
    .C(clk),
    .D(\blk00000001/sig0000004f ),
    .R(sclr),
    .Q(\blk00000001/sig0000003e )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001d  (
    .C(clk),
    .D(\blk00000001/sig00000050 ),
    .R(sclr),
    .Q(\blk00000001/sig0000003f )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001c  (
    .C(clk),
    .D(\blk00000001/sig00000051 ),
    .R(sclr),
    .Q(\blk00000001/sig00000040 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001b  (
    .C(clk),
    .D(\blk00000001/sig00000052 ),
    .R(sclr),
    .Q(\blk00000001/sig00000041 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000001a  (
    .C(clk),
    .D(\blk00000001/sig00000053 ),
    .R(sclr),
    .Q(\blk00000001/sig00000042 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000019  (
    .C(clk),
    .D(\blk00000001/sig00000054 ),
    .R(sclr),
    .Q(\blk00000001/sig00000043 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000018  (
    .C(clk),
    .D(\blk00000001/sig00000055 ),
    .R(sclr),
    .Q(\blk00000001/sig00000044 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000017  (
    .C(clk),
    .D(\blk00000001/sig00000056 ),
    .R(sclr),
    .Q(\blk00000001/sig00000045 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000016  (
    .C(clk),
    .D(\blk00000001/sig00000057 ),
    .R(sclr),
    .Q(\blk00000001/sig00000046 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000015  (
    .C(clk),
    .D(\blk00000001/sig00000058 ),
    .R(sclr),
    .Q(\blk00000001/sig00000047 )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000014  (
    .C(clk),
    .D(\blk00000001/sig00000059 ),
    .R(sclr),
    .Q(\blk00000001/sig00000048 )
  );
  RAM64X1S #(
    .INIT ( 64'hB4B4B4B4B4B4B4B4 ))
  \blk00000001/blk00000013  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004b )
  );
  RAM64X1S #(
    .INIT ( 64'hAAAAAAAAAAAAAAAA ))
  \blk00000001/blk00000012  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000049 )
  );
  RAM64X1S #(
    .INIT ( 64'h6666666666666666 ))
  \blk00000001/blk00000011  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004a )
  );
  RAM64X1S #(
    .INIT ( 64'hC738C738C738C738 ))
  \blk00000001/blk00000010  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004c )
  );
  RAM64X1S #(
    .INIT ( 64'h5295AD6A5295AD6A ))
  \blk00000001/blk0000000f  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004d )
  );
  RAM64X1S #(
    .INIT ( 64'h9B26C9B364D9364C ))
  \blk00000001/blk0000000e  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004e )
  );
  RAM64X1S #(
    .INIT ( 64'hB6925B692DB492DA ))
  \blk00000001/blk0000000d  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig0000004f )
  );
  RAM64X1S #(
    .INIT ( 64'h24DB6DB24926DB6C ))
  \blk00000001/blk0000000c  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000050 )
  );
  RAM64X1S #(
    .INIT ( 64'h38E38E3C71C71C70 ))
  \blk00000001/blk0000000b  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000051 )
  );
  RAM64X1S #(
    .INIT ( 64'h95A95A952B52B52A ))
  \blk00000001/blk0000000a  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000052 )
  );
  RAM64X1S #(
    .INIT ( 64'h8C67398CE7318CE6 ))
  \blk00000001/blk00000009  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000053 )
  );
  RAM64X1S #(
    .INIT ( 64'hD6B5AD294A5AD6B4 ))
  \blk00000001/blk00000008  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000054 )
  );
  RAM64X1S #(
    .INIT ( 64'h18C631CE739CE738 ))
  \blk00000001/blk00000007  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000055 )
  );
  RAM64X1S #(
    .INIT ( 64'h1F07C1F07C1F07C0 ))
  \blk00000001/blk00000006  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000056 )
  );
  RAM64X1S #(
    .INIT ( 64'h1FF801FF801FF800 ))
  \blk00000001/blk00000005  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000057 )
  );
  RAM64X1S #(
    .INIT ( 64'hE00001FFFFE00000 ))
  \blk00000001/blk00000004  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000058 )
  );
  RAM64X1S #(
    .INIT ( 64'hFFFFFE0000000000 ))
  \blk00000001/blk00000003  (
    .A0(a[0]),
    .A1(a[1]),
    .A2(a[2]),
    .A3(a[3]),
    .A4(a[4]),
    .A5(a[5]),
    .D(NlwRenamedSig_OI_p[0]),
    .WCLK(clk),
    .WE(NlwRenamedSig_OI_p[0]),
    .O(\blk00000001/sig00000059 )
  );
  GND   \blk00000001/blk00000002  (
    .G(NlwRenamedSig_OI_p[0])
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
