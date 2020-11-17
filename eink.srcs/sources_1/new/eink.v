// *******************************************************************
// COPYRIGHT(c)2020, Peking University 
// All rights reserved.
//
// IP LIB INDEX :  DE£¨Eink£© Display IP LIB.
// IP Name      :  Eink	
// File name    :  eink.V
// Module name  :  EINK_TOP
// Full name    :  EINK IP top module
//
// Author       :  LIU Feng
// Email        :  albert_liu@126.com
// Date         :  2020/11/15
// Version      :  v1.0 
// 
// Abstract     :  Eink IP TOP MODULE
//
// Modification history
// -------------------------------------------------------------------
// $Log$
//
// 2020/11/15  LIU Feng created vision
// 2020/11/16  redesign with simple Frame FSM by LIU Feng
//
// *******************************************************************

`include "eink_macro.v"
`include "timescale.v "


module EINK_TOP(
                //Inputs
		clk             ,
		rst             ,
		frame_update_en ,

		//outputs
		xcl             ,
		xle             ,
		xstl            ,
		ckv             ,
		mode            ,
		spv             ,
		dout
               );


//**************************
// INPUT
//**************************
input      clk;
input      rst;
input      frame_update_en;


//**************************
// OUTPUT
//**************************
output    xcl;
output    xle;
output    xstl;
output    ckv;
output    mode;
output    spv;
output    [15:0] dout;
    
//**************************
// INNER SINGAL(S) DECLARE
// *************************
//REG(S)

//reg          xcl;
reg          xle;
reg          xstl;
reg          ckv;
reg          mode;
reg          spv;
reg  [15:0]  dout;    

reg  [8:0]   pixel_cnt;
reg  [11:0]  line_cnt;

// frame FSM signal
reg [1:0] frame_cs;
reg [1:0] frame_ns;


//WIRE(S)
wire         clk;
wire         xcl;
wire         frame_update_en;
wire         rst;

// *************************
// DEFINE PARAMETER(s)
// *************************

//parameter for frame fsm
parameter  FRAME_IDLE  = 2'b00;        //Frame IDLE state
parameter  FRAME_BLANK = 2'b10;        //Frame blank state
parameter  FRAME_EN    = 2'b11;        //Frame date enable state


//*************************
// MAIN CODE
//*************************

//pixel cnt
always@(posedge clk)
begin: PIXEL_CNT_IN_A_LINE
  if(rst)
	  pixel_cnt <= 9'b0;
  if(frame_cs == FRAME_IDLE)                        //stanby in FRAME IDLE STATE
	  pixel_cnt <= 9'b0;
  else if(pixel_cnt == `PIXEL_NUM)
	  pixel_cnt <= #`UDLY 9'b0;
  else
	  pixel_cnt <= #`UDLY pixel_cnt + 1'b1;
end

//line cnt
always@(posedge clk)
begin: LINE_CNT_IN_A_FRAME
  if(rst)
	  line_cnt <= 11'b0;
  else if(frame_cs == FRAME_IDLE)                   //Stanby in FRAME IDLE STATE
	  line_cnt <= 11'b0;
  else if((line_cnt == `LINE_NUM) && (pixel_cnt == `PIXEL_NUM))
	  line_cnt <= #`UDLY 11'b0;
  else if(pixel_cnt == `PIXEL_NUM)
	  line_cnt <= #`UDLY line_cnt + 1'b1;
  else
	  line_cnt <= #`UDLY line_cnt;
end	  
        

//------------------------------------------------------------------------------
// EINK Frame FSM
// -----------------------------------------------------------------------------
//Frame FSM sequence logic 
always@(posedge clk)
begin:FRAME_FSM_UPDATE
   if(rst)
	   frame_cs <= FRAME_IDLE;
   else
	   frame_cs <= #`UDLY frame_ns;
end

//Frame FSM conbinational logic
always@(*)
begin: FRAME_FSM_CHANGE
   case(frame_cs)
      FRAME_IDLE: begin
	             if(frame_update_en == 1'b1)
			frame_ns = FRAME_BLANK; 
		     else
		        frame_ns = FRAME_IDLE;
		  end
      FRAME_BLANK:begin
	             if(line_cnt == `BLANK_LINE_NUM)
			frame_ns = FRAME_EN;
		     else
			frame_ns = FRAME_BLANK;
		  end
      FRAME_EN:   begin
	             if(line_cnt == `LINE_NUM)
			frame_ns = FRAME_IDLE;
	             else
		        frame_ns = FRAME_EN;
		  end
     default:    begin
                        frame_ns = FRAME_IDLE;
		 end
     endcase
end

//xcl signal
assign xcl = ~xstl & ~clk;


//xle signal
always@(posedge clk)
begin: XLE_SIGNAL
   if(rst)
      xle <= 1'b0;
   else if(frame_cs == FRAME_IDLE)                   //Stanby in FRAME IDLE STATE
      xle <= 1'b0;
   else if(pixel_cnt == `XLE_LE_NUM)
      xle <= #`UDLY 1'b1;
   else if(pixel_cnt == `XLE_PULSE_NUM)
      xle <= #`UDLY 1'b0;
   else
      xle <= #`UDLY xle;
end



//xstl signal
always@(posedge clk)
begin:XSTL_SIGNAL
   if(rst)
      xstl <= 1'b1;
   else if((frame_cs == FRAME_IDLE) || (frame_cs == FRAME_BLANK))     //Stanby in FRAME IDLE STATE and FRAME BLANK STATE
      xstl <= 1'b1;
   else if(pixel_cnt == `XSTL_N_LE_NUM)
      xstl <= #`UDLY 1'b0;
   else if(pixel_cnt == `XSTL_N_PULSE_NUM)  
      xstl <= #`UDLY 1'b1;
   else 
      xstl <= #`UDLY xstl;
end


//ckv signal
always@(posedge clk)
begin: CKV_SIGNAL
  if(rst)
    ckv <= 1'b0;
  else if(frame_cs == FRAME_IDLE)                   //Stanby in FRAME IDLE STATE
    ckv <= 1'b0;
  else if(pixel_cnt == `CKV_LE_NUM)
    ckv <= #`UDLY 1'b1;
  else if(pixel_cnt == `CKV_PULSE_NUM)
    ckv <= #`UDLY 1'b0;
  else
    ckv <= #`UDLY ckv;
end


//mode signal
always@(posedge clk)
begin: MODE_SIGNAL
   if(rst)
      mode <= 1'b0;
   else if(frame_cs == FRAME_IDLE)                   //Stanby in FRAME IDLE STATE
      mode <= 1'b0;
   else if((frame_cs == FRAME_BLANK) && (line_cnt == 11'b0) && (pixel_cnt == `MODE_LE_NUM))
      mode <= #`UDLY 1'b1;
   else
      mode <= #`UDLY mode;
end

//SPV signal
always@(posedge clk)
begin: SPV_SIGNAL
   if(rst)
      spv <= 1'b1;
   else if(frame_cs == FRAME_IDLE)                   //Stanby in FRAME IDLE STATE
      spv <= #`UDLY 1'b1;
   else if((frame_cs == FRAME_BLANK) && (line_cnt == 11'b0) && (pixel_cnt == `SPV_N_LE_NUM))
      spv <= #`UDLY 1'b0;
   else if((frame_cs == FRAME_BLANK) && (line_cnt == 11'b1) && (pixel_cnt == `SPV_N_LE_NUM))
      spv <= #`UDLY 1'b1;
   else
      spv <= #`UDLY spv;
end


//dout
always@(posedge clk)
begin: DOUT_SIGNAL
   if(rst)
     dout <= 16'b0;
   else if(line_cnt[1:0] == 2'b11)
     dout <= #`UDLY 16'b1111_1111_1111_1111;
   else 
     dout <= #`UDLY 16'b0;
end 

endmodule
