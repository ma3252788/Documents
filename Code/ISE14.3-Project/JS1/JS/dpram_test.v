`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:44:37 10/23/2009
// Design Name:   dpram
// Module Name:   dpram_test.v
// Project Name:  sys_613
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dpram
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dpram_test_v;

	// Inputs
	reg [15:0] addra;
	reg [13:0] addrb;
	reg clka;
	reg clkb;
	reg [7:0] dina;
	reg ena;
	reg enb;
	reg wea;

	// Outputs
	wire [31:0] doutb;
//	wire	[7:0]dina;

	// Instantiate the Unit Under Test (UUT)
	dpram uut (
		.addra(addra), 
		.addrb(addrb), 
		.clka(clka), 
		.clkb(clkb), 
		.dina(dina), 
		.doutb(doutb), 
		.ena(ena), 
		.enb(enb), 
		.wea(wea)
	);

	always #10 clka = ~clka;
	always #10 clkb = ~clkb;

	initial begin
		// Initialize Inputs
		addra = 0;
		addrb = 0;
		clka = 0;
		clkb = 0;
		dina = 0;
		ena = 1;
		enb = 0;
		wea = 1;

		// Wait 100 ns for global reset to finish
		#100;
      addra = 0; 
		dina = 1; 

		#100;
      addra = 1; 
		dina = 2; 

		#100;
      addra = 2; 
		dina = 3; 

		#100;
      addra = 3; 
		dina = 4; 

		#100;
      addra = 4; 
		dina = 5; 

		#100;
      addra = 5; 
		dina = 6; 

		#100;
      addra = 6; 
		dina = 7; 

		#100;
      addra = 7; 
		dina = 8; 

		#100;
      addrb = 0; 
 
		// Add stimulus here

	end
      
endmodule

