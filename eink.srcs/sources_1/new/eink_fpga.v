`timescale 1ns / 1ps
`include "eink_macro.v"
`include "timescale.v "

module EINK_FPGA(
    input       clk,  //100MHz
    input       btnA, //RST Button
    input       btnB, //FRAME_UPDATE Button

    output      xcl ,
    output      xle ,
    output      xstl, 
    output      ckv , 
    output      mode, 
    output      spv , 
    output      dout,
);

    //generate 10hz clock
    reg [23:0] cnt;
    reg xcl_40Hz; //1KHz
    wire xcl_40Hz_bufg;
    
    parameter PERIOD_CLK = 10000000;

    always @(posedge clk)
      begin
         if (cnt == PERIOD_CLK/2)
         begin
           cnt <= 0;
           xcl_40Hz <= ~xcl_40Hz;
         end
         else
           cnt <= cnt + 1;
      end
    
    BUFG  CLK0_BUFG_INST (.I(xcl_40Hz),
                        .O(xcl_40Hz_bufg));

    wire rst;
    wire frame_update_en;
    
    reg sync_rst0, sync_rst1;
    always @(posedge xcl_40Hz_bufg)
    begin
      sync_rst0 <= btnA;
      sync_rst1 <= sync_rst0;
    end
    assign rst = btnA | sync_rst1;
    
    reg sync_frame_update_en0, sync_frame_update_en1, sync_frame_update_en2;
    reg frame_update_en_reg;
    always @(posedge xcl_40Hz_bufg)
    begin
      sync_frame_update_en0 <= btnB;
      sync_frame_update_en1 <= sync_frame_update_en0;
      sync_frame_update_en2 <= sync_frame_update_en1;
    end
    
    always @(posedge xcl_40Hz_bufg)
    begin
      if (rst)
        frame_update_en_reg <= 0;
      else if (sync_frame_update_en2 & ~sync_frame_update_en1)
        frame_update_en_reg <= ~frame_update_en_reg;
    end
    assign frame_update_en = frame_update_en_reg;


EINK_TOP U_EINK_TOP(
        //Inputs
		.clk(xcl_40Hz_bufg)       ,
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
