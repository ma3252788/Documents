`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    18:49:54 10/30/08
// Design Name:    
// Module Name:    uart
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
module uart(clk, clk_baud, rst, rxd, din, wrn, txd, rdn, dout, data_ready, send_over);

input clk;
input clk_baud;
input rst;
input rxd;
input [7:0] din;
input rdn;
input wrn;

output txd;
output [7:0] dout;
output data_ready;
output send_over;

uart_send uart_senduu(
							.clk_sample(clk),
							.clk_baud(clk_baud),
							.rst(rst),
							.txd(txd),
							.din(din),
							.wrn(wrn),
							.send_over(send_over)
							);
uart_receive	uart_receiveuu(
										.clk_sample(clk),
										.rst(rst),
										.rxd(rxd),
										.dout(dout),
										.rdn(rdn),
										.data_ready(data_ready)
										);



endmodule
