`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    09:49:07 01/31/10
// Design Name:    
// Module Name:    Iris_enable_mask
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module Iris_enable_mask(clk, rst,  trig, foc_enable,  auto_focus_trig, auto_focus_active);

	input clk;
	input rst;

//	input trig4Iris;
	input trig;
	input foc_enable;

//	output mask;
	output auto_focus_trig;
	output auto_focus_active;

	reg	mask;
	reg	[31:0] cnt;
	 
//	always @(posedge clk or posedge trig4Iris) 
//	if(trig4Iris)	 //变倍触发
//		begin
//		 	mask <= 1'b0;
//			cnt <= 1'b0;
//		end
//	else
//		begin
//			if(cnt == 'd2950000)//=59000000*50ms，延迟50ms后释放对调光使能的控制	
//				mask <= 1'b1;	
//			else
//			begin
//				mask <= 1'b0;
//				cnt <= cnt + 1'b1;	
//			end				
//		end

	//自动调焦指令触发自动调焦
//	assign auto_focus_trig = ~trig; 
	reg	auto_focus_trig;
	reg	[31:0]	cntt;
	always @(posedge clk or posedge trig) 
	if(trig)	 //自动调焦触发
		begin
		 	auto_focus_trig <= 1'b0;
			cntt <= 0;
		end
	else
		begin
			if(cntt < 'd2950000)	//=59000000*50ms，复位50ms后启动自动调焦控制
			begin
				auto_focus_trig <= 1'b0;

				cntt <= cntt + 1'b1;	
			end				
			else
				auto_focus_trig <= 1'b1;					
		end

	reg 	flag;
	reg	auto_focus_active;
	reg	[31:0]	cnttt;
	always @(posedge clk or posedge trig or posedge foc_enable)//or negedge rst 
	if(trig)	 //触发
		begin
		 	auto_focus_active <= 1'b0;

			flag <= 1'b1;
		end
	else 
	begin
		if(foc_enable)	 //手动调焦中止自动调焦
			begin
			 	auto_focus_active <= 1'b0;

				flag <= 1'b0;
			end
		else
			begin
				auto_focus_active <= (flag)? 1'b1:1'b0;					
			end
	end

endmodule
