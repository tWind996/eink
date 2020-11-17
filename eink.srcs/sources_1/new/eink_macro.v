// *********************************************************************
// COPYRIGHT(c)2020, Peking University 
// All rights reserved.
//
// IP LIB INDEX :  DE(Eink) Display IP LIB.
// IP Name      :  Eink 
// File name    :  eink_macro.v
// Module name  :  
// Full name    :  eink macro define file
//
// Author       :  LIU Feng
// Email        :  albert_liu@126.com
// Data         :  2020/11/15
// Version      :  v1.0 
// 
// Abstract     :  define all macro(s) used in eink IP
// Called by    :  
// 
// Modification history
// ---------------------------------------------------------------------
// $Log$
//
// *********************************************************************

//******************
//DEFINE(s)
//******************
`define UDLY         1     //Unit delay, for nonblocking assignments in sequential logic

//------------------------------------------------------------------------
// DEFINE EINK TIMING NUMBER
//------------------------------------------------------------------------
`define XLE_LE_NUM          9'd002     //Eink XLE signal leading edge length
`define XLE_PULSE_NUM       9'd004     //Eink XLE signal pulse counter number
`define XSTL_N_LE_NUM       9'd014     //Eink XSTL signal pulse counter number
`define CKV_LE_NUM          9'd034     //Eink CKV signal leading edge length 
`define CKV_PULSE_NUM       9'd256     //Eink CKV signal pulse counter number
`define XSTL_N_PULSE_NUM    9'd288     //Eink XSTL signal pulse counter number
`define PIXEL_NUM           9'd288     //Pixel counter number in a line
`define LINE_NUM            11'd1654   //Line counter number in a frame
`define BLANK_LINE_NUM      3'd005     //Blank Line counter number
`define MODE_LE_NUM         9'd034     //Mode signal leading edge pixel cnt number 
`define SPV_N_LE_NUM        9'd140     //SPV signal leading edge number pixel cnt number 
`define SPV_N_NUM           9'd288     //SPV signal pulse line cnt number
