`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/10 22:45:01
// Design Name: 
// Module Name: fsm
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

module eink_top(
    input clk,
    input rst,
    input frame_fresh,
    input [9:0] MODE_WIDTH,
    //input [9:0] XCL_HIGH_WIDTH,
    //input [9:0] XCL_LOW_WIDTH,
    //input [9:0] XCL_CYCLE_WIDTH,
    input [9:0] XCL_NUM,
    input [9:0] CKV_HIGH_WIDTH,
    //input [9:0] CKV_LOW_WIDTH,
    input [9:0] CKV_CYCLE_WIDTH,
    input [9:0] CKV_NUM,

    output reg xcl,
    output xstl,
    output xle,
    output reg ckv,
    output spv,
    output mode,
    output [15:0] data
    );

    reg xcl;    // XCL signal
    reg xstl;
    reg xle;
    reg ckv;
    reg spv;
    reg mode;
    reg [15:0] data;
    
    //STATE
    parameter   STAND_BY = 5'b00000, //1
                MODE_LOW = 5'b00001, //2
                SPV_DELAY = 5'b00010, //3 ENABLE CKV
                SPV_LOW = 5'b00011,
                //SPV_AFTER = 5'b00100,
                CKV_SETUP = 5'b00101,   //6 wait util 5cycle
                //CKV_CYCLE = 5'b00110,
                XLE_DELAY = 5'b00111,  
                XLE_HIGH = 5'b01000,
                XSTL_DELAY = 5'b01001, //10
                XSTL_LOW = 5'b01010, // clk_en and count XCL_NUM
                //XCL_DELAY = 5'b01011, //12
                //XCL_EN = 5'b01100,  // ckv trigger？ ckv_num_counter trigger？
                //DATA_TRANS = 5'b01101; // xcl trigger?

    reg[4:0] cur_state;
    reg[4:0] next_state;

    always @(posedge clk or posedge rst or posedge frame_fresh)
        begin
            if(rst)
                cur_state <= STAND_BY;
            else if(frame_fresh)
                cur_state <= MODE_LOW;
            else
                cur_state <= next_state;
        end

    always @(posedge clk)
        begin
            case(cur_state)
                STAND_BY:   next_state = STAND_BY;
                MODE_LOW:
                    begin
                        if(global_counter == MODE_WIDTH)
                            begin
                                next_state = SPV_DELAY;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                SPV_DELAY: 
                    begin
                        if(global_counter == SPV_DELAY_WIDTH)
                            begin
                                next_state = SPV_LOW;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                SPV_LOW:   
                    begin
                        if(global_counter == SPV_LOW_WIDTH)
                            begin
                                next_state = CKV_SETUP;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                //5'b00100: next_state = 5'b00001;
                CKV_SETUP:   
                    begin
                        if(global_counter == CKV_SETUP_WIDTH)
                            begin
                                next_state = XLE_DELAY;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                //5'b00110: next_state = 5'b00001;
                XLE_DELAY:   
                    begin
                        if(global_counter == XLE_DELAY_WIDTH)
                            begin
                                next_state = XLE_HIGH;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                XLE_HIGH:   
                    begin
                        if(global_counter == XLE_HIGH_WIDTH)
                            begin
                                next_state = XSTL_DELAY;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                XSTL_DELAY:   
                    begin
                        if(global_counter == XSTL_DELAY_WIDTH)
                            begin
                                next_state = XSTL_LOW;
                                global_counter <= 0;
                            end
                        else    
                            begin
                                global_counter <= global_counter+1;
                                next_state = cur_state;
                            end
                    end
                XSTL_LOW:
                    begin
                        if(ckv_num_counter==CKV_NUM)
                            begin
                                next_state = 5'b00000; //STAND_BY
                                ckv_num_counter = 0;
                            end
                        else
                            begin
                                next_state = 5'b00111;
                            end
                    end
                default:    next_state = STAND_BY
        end


    reg [15:0] ckv_num_counter;
    reg [15:0] xcl_num_counter;
    
    //assgin value with state
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                mode <= 1;
            else if(cur_state == MODE_LOW)
                mode <= 0;
            else
                spv <= 1;
        end
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                spv <= 1;
            else if(cur_state == SPV_LOW)
                spv <= 0;
            else
                spv <= 1;
        end
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                xstl <= 1;
            else if(cur_state == XSTL_LOW)
                xstl <= 0;
            else
                xstl <= 1;
        end

    always @(posedge clk or posedge rst)
        begin
            if(rst)
                xle<=0;
            else  if(cur_state == XLE_HIGH)
                xle <= 1;
            else
                xle <=0;
        end                         
    
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                xcl_en <= 1;
            else if(cur_state == XSTL_LOW)
                xcl_en <= 0;
            else
                xcl_en <= 1;
        end
    always @(*)
        begin
            case(cur_state)
                5'b00000:   ckv_en = 0;
                5'b00001:   ckv_en = 0;
                5'b00010:   ckv_en = 0;
                5'b00011:   ckv_en = 1;
                //5'b00100:
                5'b00101:   ckv_en = 1;
                //5'b00110:
                5'b00111:   ckv_en = 1;
                5'b01000:   ckv_en = 1;
                5'b01001:   ckv_en = 1;
                5'b01010:   ckv_en = 1;
            endcase
        end

    //counter and set data
    always @(posedge xcl)
        begin
            if(xlc_en == 1)
                begin                        
                    if(xcl_num_counter == XCL_NUM)
                        begin
                            xcl_num_counter = 0;
                            ckv_num_counter = ckv_num_counter+1;
                        end
                    else
                        begin
                            xcl_num_counter = xcl_num_counter+1;
                            //data
                        end
                end
        end
    
    //clk div
    reg [15:0] pixel_cnt; //xcl_clk_
    reg [15:0] line_cnt;
    reg [15:0] ckv_clk_counter;
    reg [15:0] xcl_clk_counter;
    reg ckv_clk,
        ckv_en,
        xcl_en,
        xcl_clk;

    always @(posedge clk or rst)    
        begin
            if(!rst)    
                ckv_clk_counter <= 0;    
            else if(ckv_clk_counter == CKV_CYCLE_WIDTH)
                ckv_clk_counter <= 0;    
            else ckv_clk_counter <= ckv_clk_counter+1; 

            if(!rst)    
                xcl_clk_counter <= 0;    
            else if(xcl_clk_counter == XCL_CYCLE_WIDTH)
                xcl_couter <= 0;    
            else xcl_clk_counter <= xcl_clk_counter+1;  
        end

    always @(posedge clk or posedge rst)   
        begin 

            if(rst)    
                ckv_clk <= 0;    
            else if(ckv_clk_counter < CKV_HIGH_WIDTH)    
                ckv_clk <= 0;    
            else ckv_clk <= 1; 

            if(rst)    
                xcl_clk<= 0;    
            else if(xcl_clk_counter < XCL_HIGH_WIDTH)    
                xcl_clk <= 0;    
            else xcl_clk <= 1;

            assgin xcl = xcl_clk & xcl_en;
            assgin ckv = ckv_clk & ckv_en;

        end

    // always @(change_state)
    //     begin
    //         case(cur_state)
    //             5'b00000:
    //             5'b00001:
    //             5'b00010:
    //             5'b00011:
    //             //5'b00100:
    //             5'b00101:
    //             //5'b00110:
    //             5'b00111:
    //             5'b01000:
    //             5'b01001:
    //             5'b01010:
    //             5'b01011:
    //             5'b01100: 
    //     end
        // begin
        //     case(cur_state)
        //         STAND_BY
        //         MODE_LOW
        //         SPV_DELAY
        //         SPV_LOW
        //         //SPV_AFTE,
        //         CKV_SETUP
        //         //CKV_CYCL,
        //         XLE_DELAY  
        //         XLE_HIGH
        //         XSTL_DELAY
        //         XSTL_LOW
        //         XCL_DELAY
        //         XCL_EN
        //         DATA_TRANS
        //     endcase
        // end

    
endmodule
