`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:43:31 03/01/2017 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(clk,rst,clk_div2,clkout
    );
	 input clk,rst;
	 output clk_div2,clkout;
	 reg[15:0] count = 1'b0;
	 reg clk_div2;
	 reg clkout ;
	 parameter N=10000;
	 always @ (posedge clk or negedge rst)
	 begin
	 if(!rst)
		begin
			count <=0;
			clk_div2 <= 0;
			clkout <= 1;
		end
		
	else begin
			if (count == N/2-1)
				begin
					clk_div2 <= !clk_div2;
					count <= 0;
				end
				
			else
					count <= count +1;
			end
	 
	 end
endmodule