`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:16 03/16/2017 
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
module top(clk_59m,rst,ADV7179_SDA,ADV7179_SCL,ADV7179_RST,ADV7179_P,
				ADV7179_CLK,ADV7179_TTX,ADV7179_TTXREQ,ADV7179_SCRESET,ADV7179_BLANK,ADV7179_VS,
				ADV7179_HS,AD1,DA
    );
	 
	 input rst,clk_59m; 
	 
	 //ADV7179
	 input ADV7179_P;
	 output ADV7179_SDA,ADV7179_SCI,ADV7179_RST,ADV7179_CLK;
	 output ADV7179_TTX,ADV7179_TTXREQ,ADV7179_SCRESET,ADV7179_BLANK,ADV7179_VS,ADV7179_HS;
	 output [7:0] DA;
	 
	 //SYSTEM CLOCK
	 wire clk59M_DCMed;
	 wire clk10M_DCMed;
	 
	 sys_dcm dcm59m(
							.CLKIN_IN(clk_59),
							.RST_IN(!rst),
							.CLKDV_OUT(clk10M_DCMed),
							.CLKIN_IBUFG_OUT(clk59M_DCMed)	 
	 );
	 
	 adv7179_config_top adv7179_config(
							.rst(rst),
							.clk(clk59M_DCMed),
							.ADV7179_SCL(ADV7179_SCL),
							.ADV7179_SDA(ADV7179_SDA),
							.ADV7179_RST(ADV7179_RST),
							.finish7179(finish7179)	 
	 );
	 
	 assign config_done = finish7179;
	 




endmodule
