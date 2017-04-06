`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:52:03 09/07/2010
// Design Name:   adv7180_config_top
// Module Name:   test_7180.v
// Project Name:  JS
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: adv7180_config_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_7180_v;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire ADV7180_SCL;
	wire ADV7180_SDA;
	wire finish;

	// Instantiate the Unit Under Test (UUT)
	adv7180_config_top uut (
		.rst(rst), 
		.clk(clk), 
		.ADV7180_SCL(ADV7180_SCL), 
		.ADV7180_SDA(ADV7180_SDA), 
		.finish(finish)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100  rst=1;
        
		// Add stimulus here

	end
	always  #2 clk=~clk;
      
endmodule

