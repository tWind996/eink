`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/15 23:30:49
// Design Name: 
// Module Name: eink_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module eink_tb();

reg clk;
reg rst;
reg frame_update_en;

wire xcl;
wire xle;
wire xstl;
wire ckv;
wire mode;
wire spv;
wire [15:0] dout;

initial
begin
   clk = 0;
   rst = 1;
   frame_update_en = 0;
      
   #260  rst = 0;
   
   #26 frame_update_en =1;
   #39 frame_update_en =0;
   
   #100000000  $finish;
end

always
begin
   #13 clk = ~clk;
end




EINK_TOP U_EINK_TOP(
                //Inputs
		.clk(clk)       ,
		.rst(rst)       ,
		.frame_update_en(frame_update_en) ,

		//outputs
		.xcl(xcl)              ,
		.xle(xle)              ,
		.xstl(xstl)            ,
		.ckv(ckv)              ,
		.mode(mode)            ,
		.spv(spv)              ,
		.dout(dout)
               );





















endmodule
