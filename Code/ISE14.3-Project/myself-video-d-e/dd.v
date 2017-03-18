`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:16:53 03/16/2017
// Design Name:   top
// Module Name:   E:/Hardware/About-Hardware/Documents/Code/ISE14.3-Project/myself-video-d-e/dd.v
// Project Name:  myself-video-d-e
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dd;

	// Inputs
	reg clk_59m;
	reg rst;
	reg ADV7179_SCL;
	reg ADV7179_P;
	reg AD1;

	// Outputs
	wire ADV7179_SDA;
	wire ADV7179_RST;
	wire ADV7179_CLK;
	wire ADV7179_TTX;
	wire ADV7179_TTXREQ;
	wire ADV7179_SCRESET;
	wire ADV7179_BLANK;
	wire ADV7179_VS;
	wire ADV7179_HS;
	wire [7:0] DA;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk_59m(clk_59m), 
		.rst(rst), 
		.ADV7179_SDA(ADV7179_SDA), 
		.ADV7179_SCL(ADV7179_SCL), 
		.ADV7179_RST(ADV7179_RST), 
		.ADV7179_P(ADV7179_P), 
		.ADV7179_CLK(ADV7179_CLK), 
		.ADV7179_TTX(ADV7179_TTX), 
		.ADV7179_TTXREQ(ADV7179_TTXREQ), 
		.ADV7179_SCRESET(ADV7179_SCRESET), 
		.ADV7179_BLANK(ADV7179_BLANK), 
		.ADV7179_VS(ADV7179_VS), 
		.ADV7179_HS(ADV7179_HS), 
		.AD1(AD1), 
		.DA(DA)
	);

	initial begin
		// Initialize Inputs
		clk_59m = 0;
		rst = 0;
		ADV7179_SCL = 0;
		ADV7179_P = 0;
		AD1 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

