`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:58:41 09/10/2010
// Design Name:   dpram
// Module Name:   tst_dpram.v
// Project Name:  JS
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

module tst_dpram_v;

	// Inputs
	reg [15:0] addra;
	reg [12:0] addrb;
	reg clka;
	reg clkb;
	reg [7:0] dina;
	reg ena;
	reg enb;
	reg wea;

	// Outputs
	wire [63:0] doutb;

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
      addra = 8; 
		dina = 9; 

		#100;
      addra = 9; 
		dina = 10; 

		#100;
      addrb = 0; 

        
		// Add stimulus here

	end
	always #10 clka = ~clka;
	always #10 clkb = ~clkb;
endmodule

