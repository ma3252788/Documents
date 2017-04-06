`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    09:29:23 03/01/10
// Design Name:    
// Module Name:    Out_CTRL
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
module Out_CTRL(clk, ctrl, clk_in, MP_in, clk_out, MP_out);

input clk;
input ctrl;
input clk_in;
input [7:0] MP_in;
output clk_out;
output [7:0] MP_out;

reg	enable;
reg	[7:0] cnt;

always @(posedge clk or negedge ctrl)
if(!ctrl)
begin	 
	cnt <= 1'b0;

	enable <= 1'b0;
end
else
begin
	if(&cnt)
		enable <= 1'b1;
	else
	begin
		cnt <= cnt+1'b1;

		enable <= 1'b0;
	end
end

assign MP_out = (enable)? MP_in:8'h00;

assign clk_out = (enable)?clk_in:0;

endmodule
