`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:48:40 03/07/2017
// Design Name:   top
// Module Name:   E:/Hardware/ISE14.3-Project/DSP-RET-TO-1/top1.v
// Project Name:  DSP-RET-TO-1
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

module top1;

	// Outputs
	wire clkout;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clkout(clkout)
	);

	initial begin
		// Initialize Inputs

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

